import json
import os
import sys

# ==========================================
# 🔧 CONFIGURATION
# ==========================================
SCHEMA_FILE = "database_schema.json"  # Ensure this path is correct relative to where you run the script
OUTPUT_DIR = "training_data"

def load_schema_string(schema_path):
    """
    Reads the JSON schema and converts it into a compact SQL DDL string
    that the LLM can understand.
    """
    if not os.path.exists(schema_path):
        print(f"❌ Error: Schema file not found at {schema_path}")
        sys.exit(1)

    with open(schema_path, 'r') as f:
        schema_json = json.load(f)

    ddl_statements = []
    
    for table_name, details in schema_json.items():
        columns = []
        for col in details.get('columns', []):
            col_def = f"{col['name']} {col['type']}"
            # Add PK marker if applicable, though simple types are usually enough for LLM context
            if "PK" in col.get('constraints', []):
                col_def += " PRIMARY KEY"
            columns.append(col_def)
        
        # Create table string: "CREATE TABLE name (col1 type, col2 type);"
        table_def = f"CREATE TABLE {table_name} ({', '.join(columns)});"
        ddl_statements.append(table_def)

        # Add Foreign Keys as separate context hints if you prefer, 
        # or relying on the table defs is often enough. 
        # For this script, we'll keep it compact.

    return "\n".join(ddl_statements)

def format_training_entry(question, sql, schema_string):
    """
    Formats the entry into the exact prompt structure required by Defog/Llama-3.
    """
    prompt = f"""### Task
Generate a SQL query to answer the following question:
`{question}`

### Database Schema
This query will run on a database whose schema is represented in this string:
{schema_string}

### SQL
{sql}"""
    
    # We return a JSON object with the "text" field
    return {"text": prompt}

def main():
    print("==================================================")
    print("🤖 CENQUERY TRAINING DATA GENERATOR")
    print("==================================================")

    # 1. Setup
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    
    schema_string = load_schema_string(SCHEMA_FILE)
    print(f"✅ Schema loaded ({len(schema_string)} chars).")

    # 2. Get User Info
    member_name = input("Enter your name (e.g., Member1): ").strip().replace(" ", "_")
    output_filename = os.path.join(OUTPUT_DIR, f"train_{member_name}.jsonl")
    
    print(f"📂 Saving data to: {output_filename}")
    print("--------------------------------------------------")
    print("Instructions:")
    print("1. Type your natural language question.")
    print("2. Type the corresponding SQL query (single line preferred).")
    print("3. Type 'EXIT' as the question to stop.")
    print("--------------------------------------------------")

    # 3. Input Loop
    count = 0
    while True:
        print(f"\n📝 Entry #{count + 1}")
        question = input("QUESTION: ").strip()
        
        if question.upper() == 'EXIT':
            break
        if not question:
            print("⚠️  Question cannot be empty.")
            continue

        sql = input("SQL QUERY: ").strip()
        if not sql:
            print("⚠️  SQL cannot be empty.")
            continue
        
        # Simple validation guardrail
        if not sql.upper().startswith("SELECT"):
            confirm = input("⚠️  Warning: Query does not start with SELECT. Continue? (y/n): ")
            if confirm.lower() != 'y':
                continue

        # 4. Format and Save
        entry_json = format_training_entry(question, sql, schema_string)
        
        try:
            with open(output_filename, 'a', encoding='utf-8') as f:
                f.write(json.dumps(entry_json) + "\n")
            count += 1
            print("✅ Saved.")
        except Exception as e:
            print(f"❌ Error saving entry: {e}")

    print("==================================================")
    print(f"👋 Done! You added {count} entries.")
    print(f"📁 File: {output_filename}")

if __name__ == "__main__":
    main()
import json
import os
import sys

# ==========================================
# 🔧 CONFIGURATION
# ==========================================
SCHEMA_FILE = "database_schema.json"  # Your schema file
QUESTIONS_FILE = "questions.txt"      # File containing list of questions
SQL_FILE = "queries.sql"              # File containing list of SQL queries
OUTPUT_DIR = "training_data"

def load_schema_string(schema_path):
    """
    Reads the JSON schema and converts it into a compact SQL DDL string.
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
            if "PK" in col.get('constraints', []):
                col_def += " PRIMARY KEY"
            columns.append(col_def)
        
        table_def = f"CREATE TABLE {table_name} ({', '.join(columns)});"
        ddl_statements.append(table_def)

    return "\n".join(ddl_statements)

def format_training_entry(question, sql, schema_string):
    """
    Formats the entry into the exact prompt structure required by the model.
    """
    prompt = f"""### Task
Generate a SQL query to answer the following question:
`{question}`

### Database Schema
This query will run on a database whose schema is represented in this string:
{schema_string}

### SQL
{sql}"""
    
    return {"text": prompt}

def load_file_lines(filepath):
    """Reads a file and returns a list of non-empty lines."""
    if not os.path.exists(filepath):
        print(f"❌ Error: Input file not found at {filepath}")
        return []
        
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip()]
    return lines

def get_unique_filename(directory, filename):
    """
    Checks if a file exists. If so, adds (1), (2), etc. to the filename.
    """
    base, ext = os.path.splitext(filename)
    counter = 1
    new_filename = filename
    
    while os.path.exists(os.path.join(directory, new_filename)):
        new_filename = f"{base}({counter}){ext}"
        counter += 1
        
    return os.path.join(directory, new_filename)

def main():
    print("==================================================")
    print("🤖 CENQUERY BULK GENERATOR (FILE BASED)")
    print("==================================================")

    # 1. Setup
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    
    # 2. Get Member Name
    member_name = input("Enter your name (e.g., Member3): ").strip().replace(" ", "_")
    if not member_name:
        print("⚠️  No name entered, defaulting to 'Unknown_Member'")
        member_name = "Unknown_Member"

    base_filename = f"train_{member_name}_bulk.jsonl"

    # 3. Load Schema
    schema_string = load_schema_string(SCHEMA_FILE)
    print(f"✅ Schema loaded.")

    # 4. Load Questions and Queries
    questions = load_file_lines(QUESTIONS_FILE)
    queries = load_file_lines(SQL_FILE)

    print(f"📊 Loaded {len(questions)} questions from {QUESTIONS_FILE}")
    print(f"📊 Loaded {len(queries)} queries from {SQL_FILE}")

    # 5. Validation
    if len(questions) != len(queries):
        print(f"⚠️  MISMATCH: You have {len(questions)} questions but {len(queries)} queries.")
        print("❌ Please ensure both files have the exact same number of lines.")
        sys.exit(1)

    if len(questions) == 0:
        print("❌ Files are empty. Nothing to process.")
        sys.exit(1)

    # 6. Get Unique Filename
    output_path = get_unique_filename(OUTPUT_DIR, base_filename)
    
    # 7. Process and Save
    with open(output_path, 'w', encoding='utf-8') as f_out:
        for q, s in zip(questions, queries):
            entry = format_training_entry(q, s, schema_string)
            f_out.write(json.dumps(entry) + "\n")

    print("--------------------------------------------------")
    print(f"✅ Success! Generated {len(questions)} training examples.")
    print(f"📂 Output saved to: {output_path}")
    print("==================================================")

if __name__ == "__main__":
    main()
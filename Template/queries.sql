SELECT rs.tot_p FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE r.area_name = 'Kerala' AND rel.religion_name = 'Muslim' AND t.name = 'Total';
SELECT ls.person FROM language_stats ls JOIN regions r ON ls.state = r.state JOIN languages l ON ls.language_id = l.id JOIN tru t ON ls.tru_id = t.id WHERE r.area_name = 'Uttar Pradesh' AND l.name = 'Hindi' AND t.name = 'Total';
SELECT t.name AS area_type, rs.tot_p FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE r.area_name = 'Goa' AND rel.religion_name = 'Christian' AND t.name IN ('Rural', 'Urban');
SELECT l.name, ls.person FROM language_stats ls JOIN regions r ON ls.state = r.state JOIN languages l ON ls.language_id = l.id JOIN tru t ON ls.tru_id = t.id WHERE r.area_name = 'Karnataka' AND t.name = 'Total' ORDER BY ls.person DESC LIMIT 3;
SELECT rel.religion_name, (SUM(rs.p_lit) * 100.0 / NULLIF(SUM(rs.tot_p), 0)) as literacy_rate FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE r.area_name = 'India' AND t.name = 'Total' GROUP BY rel.religion_name ORDER BY literacy_rate DESC LIMIT 1;
SELECT ls.female FROM language_stats ls JOIN regions r ON ls.state = r.state JOIN languages l ON ls.language_id = l.id JOIN tru t ON ls.tru_id = t.id WHERE r.area_name = 'Tamil Nadu' AND l.name = 'Tamil' AND t.name = 'Total';
SELECT rs.non_work_p FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE r.area_name = 'Maharashtra' AND rel.religion_name = 'Jain' AND t.name = 'Total';
SELECT ls.person FROM language_stats ls JOIN regions r ON ls.state = r.state JOIN languages l ON ls.language_id = l.id JOIN tru t ON ls.tru_id = t.id WHERE r.area_name = 'West Bengal' AND l.name = 'Bengali' AND t.name = 'Rural';
SELECT r.area_name, rs.tot_p FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE rel.religion_name = 'Sikh' AND r.area_name IN ('Punjab', 'Haryana') AND t.name = 'Total' ORDER BY rs.tot_p DESC;
SELECT (rs.m_lit - rs.f_lit) as literacy_gap FROM religion_stats rs JOIN regions r ON rs.state = r.state JOIN religions rel ON rs.religion_id = rel.id JOIN tru t ON rs.tru_id = t.id WHERE r.area_name = 'India' AND rel.religion_name = 'Hindu' AND t.name = 'Total';

SELECT r.area_name AS state_name, SUM(p.persons) AS total_population
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Total'
GROUP BY r.area_name
ORDER BY total_population DESC;

SELECT r.area_name AS state_name, SUM(p.persons) AS rural_population
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Rural'
GROUP BY r.area_name
ORDER BY rural_population DESC
LIMIT 5;

SELECT r.area_name AS state_name, SUM(p.persons) AS urban_population
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Urban'
GROUP BY r.area_name
ORDER BY urban_population DESC
LIMIT 5;

SELECT r.area_name AS state_name,
(SUM(p.females) * 1000.0 / NULLIF(SUM(p.males), 0)) AS sex_ratio
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Total'
GROUP BY r.area_name
ORDER BY sex_ratio DESC;

SELECT r.area_name AS state_name,
ABS(
(SUM(CASE WHEN t.name = 'Urban' THEN p.females ELSE 0 END) * 1000.0 /
 NULLIF(SUM(CASE WHEN t.name = 'Urban' THEN p.males ELSE 0 END), 0))
-
(SUM(CASE WHEN t.name = 'Rural' THEN p.females ELSE 0 END) * 1000.0 /
 NULLIF(SUM(CASE WHEN t.name = 'Rural' THEN p.males ELSE 0 END), 0))
) AS sex_ratio_difference
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
GROUP BY r.area_name
ORDER BY sex_ratio_difference DESC;

SELECT age, SUM(persons) AS total_population
FROM population_stats
GROUP BY age
ORDER BY total_population DESC
LIMIT 3;

SELECT r.area_name AS state_name, t.name AS area_type, p.age, SUM(p.persons) AS population
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
GROUP BY r.area_name, t.name, p.age
ORDER BY r.area_name, t.name, p.age;

SELECT r.area_name AS state_name, SUM(p.persons) AS rural_children
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Rural' AND p.age = '0-6'
GROUP BY r.area_name
ORDER BY rural_children DESC
LIMIT 1;

SELECT r.area_name AS state_name,
(SUM(p.females) * 100.0 / NULLIF(SUM(p.persons), 0)) AS female_percentage
FROM population_stats p
JOIN regions r ON p.state = r.state
JOIN tru t ON p.tru_id = t.id
WHERE t.name = 'Total'
GROUP BY r.area_name;

WITH rural_totals AS (
  SELECT state, SUM(persons) AS total_persons
  FROM population_stats p
  JOIN tru t ON p.tru_id = t.id
  WHERE t.name = 'Rural'
  GROUP BY state
),
ranked_ages AS (
  SELECT p.state, p.age,
  SUM(p.persons) * 1.0 / rt.total_persons AS share,
  ROW_NUMBER() OVER (PARTITION BY p.state ORDER BY SUM(p.persons) DESC) AS rn
  FROM population_stats p
  JOIN tru t ON p.tru_id = t.id
  JOIN rural_totals rt ON p.state = rt.state
  WHERE t.name = 'Rural'
  GROUP BY p.state, p.age, rt.total_persons
)
SELECT r.area_name AS state_name, age
FROM ranked_ages ra
JOIN regions r ON ra.state = r.state
WHERE rn = 1;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END);

SELECT r.area_name, SUM(p.males) AS total_males FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY total_males DESC LIMIT 1;

SELECT r.area_name, SUM(p.females) AS total_females FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY total_females DESC LIMIT 1;

SELECT r.area_name, ABS(SUM(p.males)-SUM(p.females)) AS gender_gap FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY gender_gap DESC;

SELECT r.area_name, SUM(CASE WHEN p.age IN ('0-6','7-14','15-19') THEN p.persons ELSE 0 END) AS young_pop FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY young_pop DESC;

SELECT r.area_name, SUM(CASE WHEN p.age IN ('60+','65+') THEN p.persons ELSE 0 END) AS elderly_pop FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY elderly_pop DESC;

SELECT r.area_name, SUM(p.persons) AS urban_pop FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Urban' GROUP BY r.area_name ORDER BY urban_pop DESC;

SELECT r.area_name, SUM(p.persons) AS rural_pop FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Rural' GROUP BY r.area_name ORDER BY rural_pop DESC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name HAVING ABS(SUM(p.males)-SUM(p.females)) < 0.02 * SUM(p.persons);

SELECT r.area_name, SUM(p.persons) AS total_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY total_population ASC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Rural' GROUP BY r.area_name HAVING SUM(p.females) > SUM(p.males);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Urban' GROUP BY r.area_name HAVING SUM(p.females) > SUM(p.males);

SELECT r.area_name, SUM(p.persons) AS children_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age='0-6' GROUP BY r.area_name ORDER BY children_population DESC;

SELECT r.area_name, SUM(p.persons) AS elderly_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age IN ('60+','65+') GROUP BY r.area_name ORDER BY elderly_population ASC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END) > 2 * SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END) > 2 * SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name HAVING ABS(SUM(p.males)-SUM(p.females)) < 0.01 * SUM(p.persons);

SELECT r.area_name, SUM(p.persons) AS rural_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Rural' GROUP BY r.area_name ORDER BY rural_population ASC;

SELECT r.area_name, SUM(p.persons) AS urban_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Urban' GROUP BY r.area_name ORDER BY urban_population ASC;

SELECT r.area_name, SUM(p.persons) AS elderly_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age IN ('60+','65+') GROUP BY r.area_name ORDER BY elderly_population DESC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name HAVING SUM(CASE WHEN p.age IN ('60+','65+') THEN p.persons ELSE 0 END) > SUM(CASE WHEN p.age='0-6' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Urban' GROUP BY r.area_name HAVING SUM(p.males) > SUM(p.females);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Rural' GROUP BY r.area_name HAVING SUM(p.females) > SUM(p.males);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END) > 3 * SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END) > 3 * SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END);

SELECT r.area_name, SUM(p.persons) AS working_age_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age NOT IN ('0-6','60+','65+') GROUP BY r.area_name ORDER BY working_age_population DESC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING ABS(SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END)-SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END)) < 0.05 * SUM(p.persons);

SELECT r.area_name, SUM(p.persons) AS rural_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Rural' GROUP BY r.area_name ORDER BY rural_population DESC;

SELECT r.area_name, SUM(p.persons) AS urban_population FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Urban' GROUP BY r.area_name ORDER BY urban_population DESC;

SELECT r.area_name, ABS(SUM(p.males)-SUM(p.females)) AS gender_diff FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY gender_diff ASC;

SELECT r.area_name, SUM(p.females) AS total_females FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY total_females DESC;

SELECT r.area_name, SUM(p.males) AS total_males FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' GROUP BY r.area_name ORDER BY total_males DESC;

SELECT r.area_name, SUM(p.persons) * 1.0 / (SELECT SUM(persons) FROM population_stats ps WHERE ps.state=p.state AND ps.tru_id=p.tru_id) AS child_share FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age='0-6' GROUP BY r.area_name, p.state, p.tru_id ORDER BY child_share DESC;

SELECT r.area_name, SUM(p.persons) * 1.0 / (SELECT SUM(persons) FROM population_stats ps WHERE ps.state=p.state AND ps.tru_id=p.tru_id) AS elderly_share FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id WHERE t.name='Total' AND p.age IN ('60+','65+') GROUP BY r.area_name, p.state, p.tru_id ORDER BY elderly_share DESC;

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END) > SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END);

SELECT r.area_name FROM population_stats p JOIN regions r ON p.state=r.state JOIN tru t ON p.tru_id=t.id GROUP BY r.area_name HAVING ABS(SUM(CASE WHEN t.name='Urban' THEN p.persons ELSE 0 END)-SUM(CASE WHEN t.name='Rural' THEN p.persons ELSE 0 END)) < 0.1 * SUM(p.persons);

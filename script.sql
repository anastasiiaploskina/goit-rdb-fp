-- 1
CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

SELECT * FROM infectious_cases;

SELECT COUNT(*) FROM infectious_cases;


-- 2
CREATE TABLE IF NOT EXISTS entities
(
entity_id INT AUTO_INCREMENT PRIMARY KEY,
entity VARCHAR(50) NOT NULL,
code VARCHAR(50) NOT NULL
);


INSERT INTO entities(entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;


CREATE TABLE IF NOT EXISTS normalized_infectious_cases
(
record_id INT AUTO_INCREMENT PRIMARY KEY,
entity_id INT NOT NULL,
year INT NOT NULL,
number_yaws INT NULL,
polio_cases INT NULL,
guinea_worm_cases INT NULL,
number_rabies DECIMAL(20, 4) NULL,
number_malaria DECIMAL(20, 4) NULL,
number_hiv DECIMAL(20, 4) NULL,
number_tuberculosis DECIMAL(20, 4) NULL,
number_smallpox INT NULL,
number_cholera_cases INT NULL,
FOREIGN KEY(entity_id) REFERENCES entities(entity_id)
);


INSERT INTO normalized_infectious_cases(
	entity_id,
	year,
	number_yaws,
	polio_cases,
    guinea_worm_cases,
    number_rabies,
    number_malaria,
    number_hiv,
    number_tuberculosis,
    number_smallpox,
    number_cholera_cases
)
SELECT 
    e.entity_id,
    ic.Year,
    NULLIF(ic.Number_yaws, ''),
    NULLIF(ic.polio_cases, ''),
    NULLIF(ic.cases_guinea_worm, ''),
    NULLIF(ic.Number_rabies, ''),
    NULLIF(ic.Number_malaria, ''),
    NULLIF(ic.Number_hiv, ''),
    NULLIF(ic.Number_tuberculosis, ''),
    NULLIF(ic.Number_smallpox, ''),
    NULLIF(ic.Number_cholera_cases, '')
FROM infectious_cases ic
JOIN entities e
ON ic.Entity = e.entity;


SELECT COUNT(*) FROM normalized_infectious_cases;


-- 3
SELECT
	entity_id, 
    AVG(number_rabies) average,
    MIN(number_rabies) minimum,
    MAX(number_rabies) maximum,
    SUM(number_rabies) sum
FROM normalized_infectious_cases
WHERE number_rabies IS NOT NULL
GROUP BY entity_id
ORDER BY average DESC
LIMIT 10;


-- 4
SELECT 
	STR_TO_DATE(CONCAT(year, "-01-01"), "%Y-%d-%m") full_date,
	CURDATE() today,
	TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(year, "-01-01"), "%Y-%d-%m"), CURDATE()) year_diff
FROM normalized_infectious_cases;


-- 5
DROP FUNCTION IF EXISTS Years_difference;

DELIMITER //

CREATE FUNCTION Years_difference(input_value INT)
RETURNS INT
DETERMINISTIC
NO SQL

BEGIN
	RETURN TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(input_value, "-01-01"), "%Y-%d-%m"), CURDATE());
END //

DELIMITER ;

SELECT 
	STR_TO_DATE(CONCAT(year, "-01-01"), "%Y-%d-%m") full_date,
	CURDATE() today,
	Years_difference(year) year_diff
FROM normalized_infectious_cases;

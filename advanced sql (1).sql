SELECT SUM(population) AS total_population
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE zipcode = '94085';
--2. I need number of Male and Female head count in zipcode 94085 (Sunnyvale CA)
SELECT gender, SUM(population) AS head_count
FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
WHERE zipcode = '94085'
GROUP BY gender;
--3. I want which Age group has max headcount for both male and female genders combine (zipcode 94085 (Sunnyvale CA))
WITH population_by_zip_gender_age AS (
    SELECT 
        gender,
        MIN(minimum_age) AS min_age,
        MAX(maximum_age) AS max_age,
        SUM(population) AS headcount,
        ROW_NUMBER() OVER(ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE zipcode = '76012'
    GROUP BY gender
)
SELECT gender, min_age, max_age, headcount
FROM population_by_zip_gender_age
WHERE rank = 1;

--4. I want age group for male gender which has max male population zipcode 94085 (Sunnyvale CA))
WITH male_age_groups AS (
    SELECT 
        MIN(minimum_age) AS min_age,
        MAX(maximum_age) AS max_age,
        SUM(population) AS male_population,
        ROW_NUMBER() OVER(ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE zipcode = '94085' AND gender = 'male'
    GROUP BY gender
)
SELECT min_age, max_age, male_population
FROM male_age_groups
WHERE rank = 1;

--5. I want age group for female gender which has max male population zipcode 94085 (Sunnyvale CA))
WITH female_age_groups AS (
    SELECT 
        MIN(minimum_age) AS min_age,
        MAX(maximum_age) AS max_age,
        SUM(population) AS female_population,
        ROW_NUMBER() OVER(ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE zipcode = '94085' AND gender = 'female'
    GROUP BY gender
)
SELECT min_age, max_age, female_population
FROM female_age_groups
WHERE rank = 1;

--6. I want zipcode which has highest male and female population in USA
WITH zipcode_populations AS (
    SELECT 
        zipcode,
        gender,
        SUM(population) AS total_population,
        ROW_NUMBER() OVER(PARTITION BY gender ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE gender IN ('male', 'female')
    GROUP BY zipcode, gender
)
SELECT zipcode, gender, total_population
FROM zipcode_populations
WHERE rank = 1;

--7. I want first five age groups which has highest male and female population in USA
WITH age_groups AS (
    SELECT 
        gender,
        minimum_age,
        maximum_age,
        SUM(population) AS population,
        ROW_NUMBER() OVER(PARTITION BY gender ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE gender IN ('male', 'female')
    GROUP BY gender, minimum_age, maximum_age
)
SELECT gender, minimum_age, maximum_age, population
FROM age_groups
WHERE rank <= 5
ORDER BY gender, rank;

--8. I want first five zipcodes which has highest female population in entire USA
WITH zipcode_male_populations AS (
    SELECT 
        zipcode,
        SUM(population) AS total_population,
        ROW_NUMBER() OVER(ORDER BY SUM(population) DESC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE gender = 'male'
    GROUP BY zipcode
)
SELECT zipcode, total_population
FROM zipcode_male_populations
WHERE rank <= 5;

--9. I want first 10 which has lowest male population in entire USA
WITH zipcode_male_populations AS (
    SELECT 
        zipcode,
        SUM(population) AS total_population,
        RANK() OVER(ORDER BY SUM(population) ASC) AS rank
    FROM `bigquery-public-data.census_bureau_usa.population_by_zip_2010`
    WHERE gender = 'male'
    GROUP BY zipcode
)
SELECT zipcode, total_population
FROM zipcode_male_populations
WHERE rank <= 10;
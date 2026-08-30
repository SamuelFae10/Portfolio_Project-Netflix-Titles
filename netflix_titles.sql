-- PostgreSQL Project: Netflix Catalog EDA
-- Dataset: Netflix Movies and TV Shows (Kaggle)
-- Source file: netflix_titles.csv
-- Table: netflix_titles (already imported via pandas)


-- 1. DATA CLEANING

-- Fix rows where duration ended up in the rating column by mistake
UPDATE netflix_titles
SET duration = rating,
    rating = NULL
WHERE rating ~ '^[0-9]+ min$';

-- Fill missing ratings with a placeholder
UPDATE netflix_titles
SET rating = 'Unavailable'
WHERE rating IS NULL;

-- Convert date_added text into a real DATE column
ALTER TABLE netflix_titles ADD COLUMN IF NOT EXISTS date_added_clean DATE;

UPDATE netflix_titles
SET date_added_clean = TO_DATE(TRIM(date_added), 'FMMonth DD, YYYY')
WHERE date_added IS NOT NULL AND TRIM(date_added) != '';


-- EXPLORATORY DATA ANALYSIS (EDA)

-- 1. Movies vs TV Shows share
SELECT 
    type,
    COUNT(*) AS total_titles,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
GROUP BY type;


-- 2. Top 10 countries by number of titles
-- STRING_TO_ARRAY splits multi-country cells, UNNEST expands into rows
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS primary_country,
    COUNT(*) AS total_content
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY primary_country
ORDER BY total_content DESC
LIMIT 10;


-- 3. How many titles were added per year
SELECT 
    EXTRACT(YEAR FROM date_added_clean) AS year_added,
    COUNT(*) AS total_added,
    SUM(CASE WHEN type = 'Movie' THEN 1 ELSE 0 END) AS movies_added,
    SUM(CASE WHEN type = 'TV Show' THEN 1 ELSE 0 END) AS tv_shows_added
FROM netflix_titles
WHERE date_added_clean IS NOT NULL
GROUP BY year_added
ORDER BY year_added DESC;


-- 4. Most common ratings, split by type
SELECT 
    rating,
    type,
    COUNT(*) AS total_count
FROM netflix_titles
GROUP BY rating, type
ORDER BY total_count DESC;


-- 5. Top 10 genres (same split/expand trick as countries)
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY genre
ORDER BY total_titles DESC
LIMIT 10;


-- 6. Longest movies (extract number from "X min")
SELECT 
    title,
    duration,
    CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS duration_minutes
FROM netflix_titles
WHERE type = 'Movie' AND duration LIKE '%min'
ORDER BY duration_minutes DESC
LIMIT 10;


-- 7. TV shows with most seasons
SELECT 
    title,
    duration AS total_seasons,
    CAST(SPLIT_PART(duration, ' ', 1) AS INT) AS number_of_seasons
FROM netflix_titles
WHERE type = 'TV Show' AND duration LIKE '%Season%'
ORDER BY number_of_seasons DESC
LIMIT 10;


-- 8. Directors with most titles
SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name,
    COUNT(*) AS total_productions
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY director_name
ORDER BY total_productions DESC
LIMIT 10;


-- 9. Running total of catalog size over the years
WITH yearly_counts AS (
    SELECT 
        EXTRACT(YEAR FROM date_added_clean) AS year_added,
        COUNT(*) AS yearly_added
    FROM netflix_titles
    WHERE date_added_clean IS NOT NULL
    GROUP BY year_added
)
SELECT 
    year_added,
    yearly_added,
    SUM(yearly_added) OVER (ORDER BY year_added) AS cumulative_catalog_size
FROM yearly_counts
ORDER BY year_added ASC;


-- 10. Movies added the same year they were released
SELECT 
    release_year,
    COUNT(*) AS released_and_added_same_year
FROM netflix_titles
WHERE release_year = EXTRACT(YEAR FROM date_added_clean)
  AND type = 'Movie'
GROUP BY release_year
ORDER BY release_year DESC;
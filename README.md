Netflix Catalog EDA - PostgreSQL

Exploratory Data Analysis (EDA) project on the Netflix Movies and TV Shows dataset (Kaggle), using PostgreSQL for data cleaning and analysis.

Dataset: https://www.kaggle.com/datasets/shivamb/netflix-shows


About the dataset

The dataset contains 8,807 titles (movies and TV shows) available on Netflix, with information such as director, cast, country, date added, release year, rating, duration, and genre.

File: netflix_titles.csv
Rows: 8,807
Columns: show_id, type, title, director, cast, country, date_added, release_year, rating, duration, listed_in, description


What this project does

1. Imports the CSV into a PostgreSQL table (netflix_titles) via a Python/pandas script.

2. Cleans the raw data:
- Renames the cast column to cast_members, since cast is a reserved keyword in PostgreSQL.
- Fixes a known data issue where a handful of rows have a duration value (example: "74 min") mistakenly stored in the rating column instead of duration.
- Fills missing ratings with 'Unavailable'.
- Converts the date_added text field (example: "September 25, 2021") into a proper DATE column.

3. Analyzes the cleaned data with 10 SQL queries covering:
- Movie vs TV Show split
- Top 10 content-producing countries
- Yearly content growth trend
- Most common content ratings
- Top 10 genres
- Longest movies by runtime
- TV shows with the most seasons
- Directors with the most titles
- Cumulative catalog growth over time
- Titles added the same year they were released


Problems solved / found

Reserved keyword conflict: the cast column could not be queried directly without quoting it every time ("cast"), since CAST is a SQL function. Solved by renaming it once to cast_members.

Misplaced data: found rows where duration values had leaked into the rating column, a known quirk of this dataset, and corrected them before running any duration-based analysis.

Inconsistent date formatting: date_added was stored as free text ("September 25, 2021"), not a date type, which blocks any date-based filtering, sorting, or extraction. Solved by parsing it into a real DATE column with TO_DATE(..., 'FMMonth DD, YYYY').

Multi-value fields: columns like country, listed_in (genre), and director can hold multiple comma-separated values in a single cell, which would otherwise skew counts. Solved with STRING_TO_ARRAY plus UNNEST to split them into individual rows before aggregating.

Re-run safety: the column rename step is wrapped in a conditional check, so the script does not throw an error if it is executed more than once.


Key findings

Movies make up about 70 percent of the catalog (6,131 titles) versus TV Shows (2,676 titles).

The United States is by far the largest content producer (3,690 titles), followed by India and the United Kingdom.

Content additions grew sharply between 2016 and 2019, then declined. 2021 appears lower simply because the dataset was collected mid-year.

International Movies and Dramas are the most common genres in the catalog.


Tech stack

PostgreSQL - database and analysis queries
Python (pandas and SQLAlchemy) - CSV import into PostgreSQL
pgAdmin - database management and GUI


How to run this project

1. Create a PostgreSQL database (example: NetflixTitles).

2. Run the Python import script to load netflix_titles.csv into the database:
pip install pandas sqlalchemy psycopg2-binary openpyxl
python importar.py

3. Open netflix_titles.sql in pgAdmin's Query Tool (or run it via psql) and execute it top to bottom. It handles cleaning first, then runs the analysis queries.

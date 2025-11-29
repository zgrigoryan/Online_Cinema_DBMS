-- 1) Drop & recreate staging table
DROP TABLE IF EXISTS imdb_raw;

CREATE TABLE imdb_raw (
    movie_title    text,
    run_time       text,
    rating         text,
    user_rating    text,
    generes        text,
    overview       text,
    plot_kyeword   text,   
    director       text,
    top5_casts     text,
    writer         text,
    year           text,
    path           text
);


-- 2) Load CSV into imdb_raw
COPY imdb_raw
FROM '/tmp/imdb25k.csv' -- change to actual path later 
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"',
    ENCODING 'UTF8'
);
TRUNCATE TABLE movie RESTART IDENTITY CASCADE;

-- 3) Insert from imdb_raw into movie
INSERT INTO movie (title, description, genre, duration, release_year, movie_rating)
SELECT
    movie_title AS title,
    overview    AS description,
    COALESCE(LEFT(generes, 95), 'Unknown') AS genre,
    90 + (ROW_NUMBER() OVER () % 60)       AS duration,
    CASE
        WHEN substring(year from '\d{4}') IS NOT NULL
        THEN make_date(substring(year from '\d{4}')::int, 1, 1)
        ELSE NULL
    END AS release_year,
    NULLIF(rating, 'not-released')::numeric(10,2) AS movie_rating
FROM imdb_raw
WHERE movie_title IS NOT NULL
LIMIT 200;

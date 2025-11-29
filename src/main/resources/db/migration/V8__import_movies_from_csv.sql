-- Import additional movies from curated CSV extracted from schema/dml/25k IMDb movie Dataset.csv
CREATE TEMP TABLE tmp_import_movie (
    title TEXT,
    description TEXT,
    genre TEXT,
    duration INTEGER,
    release_year DATE,
    movie_rating NUMERIC
);

COPY tmp_import_movie (title, description, genre, duration, release_year, movie_rating)
FROM 'classpath:db/migration/movies_import.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO movie (title, description, genre, duration, release_year, movie_rating)
SELECT t.title,
       t.description,
       COALESCE(NULLIF(t.genre, ''), 'Unknown'),
       COALESCE(NULLIF(t.duration, 0), 100),
       COALESCE(t.release_year, CURRENT_DATE),
       NULLIF(t.movie_rating, 0)
FROM tmp_import_movie t
WHERE NOT EXISTS (
    SELECT 1 FROM movie m WHERE lower(m.title) = lower(t.title)
);

DROP TABLE tmp_import_movie;

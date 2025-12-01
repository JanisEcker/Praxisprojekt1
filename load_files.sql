CREATE TABLE books_data (
    title TEXT,
    description TEXT,
    authors TEXT,
    image TEXT,
    preview_link TEXT,
    publisher TEXT,
    published_date TEXT,
    info_link TEXT,
    categories TEXT,
    ratings_count NUMERIC
);

COPY books_data(
    title,
    description,
    authors,
    image,
    preview_link,
    publisher,
    published_date,
    info_link,
    categories,
    ratings_count
)
FROM '/data/books_data.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE books_data ADD COLUMN published_date_unix BIGINT;

UPDATE books_data
SET published_date_unix = 
    CASE
        WHEN published_date ~ '^\d{4}-\d{2}-\d{2}$' THEN 
            EXTRACT(EPOCH FROM TO_TIMESTAMP(published_date, 'YYYY-MM-DD'))
        WHEN published_date ~ '^\d{4}-\d{2}$' THEN 
            EXTRACT(EPOCH FROM TO_TIMESTAMP(published_date || '-01', 'YYYY-MM-DD'))
        WHEN published_date ~ '^\d{4}$' THEN 
            EXTRACT(EPOCH FROM TO_TIMESTAMP(published_date || '-01-01', 'YYYY-MM-DD'))
        ELSE NULL
    END;




-- ANDERER DATENSATZ:
CREATE TABLE reviews_data (
    id TEXT,
    title TEXT,
    price NUMERIC,
    user_id TEXT,
    profile_name TEXT,
    review_helpful_votes INT,
    review_total_votes INT,
    review_score NUMERIC,
    review_time TEXT,
    review_summary TEXT,
    review_text TEXT
);

CREATE TEMP TABLE tmp_reviews_data (
    id TEXT,
    title TEXT,
    price NUMERIC,
    user_id TEXT,
    profile_name TEXT,
    review_helpfulness TEXT,
    review_score NUMERIC,
    review_time TEXT,
    review_summary TEXT,
    review_text TEXT
);

COPY tmp_reviews_data(
    id,
    title,
    price,
    user_id,
    profile_name,
    review_helpfulness,
    review_score,
    review_time,
    review_summary,
    review_text
)
FROM '/data/Books_rating.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO reviews_data(
    id,
    title,
    price,
    user_id,
    profile_name,
    review_helpful_votes,
    review_total_votes,
    review_score,
    review_time,
    review_summary,
    review_text
)
SELECT
    id,
    title,
    price,
    user_id,
    profile_name,
    split_part(review_helpfulness, '/', 1)::INT AS review_helpful_votes,
    split_part(review_helpfulness, '/', 2)::INT AS review_total_votes,
    review_score,
    review_time,
    review_summary,
    review_text
FROM tmp_reviews_data;

DROP TABLE tmp_reviews_data;


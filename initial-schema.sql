-- DATABASE SYSTEMS: PROJECT SPRINT 2 --

-- CREATE DATABASE
DROP DATABASE IF EXISTS movie_rating_db;
CREATE DATABASE movie_rating_db;
USE movie_rating_db;

-- 1. Entity 'movie'
CREATE TABLE movie (
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    average_rating DECIMAL(3,1),
    PRIMARY KEY (title, release_year)
);

-- 2. Entity 'cast_crew'
CREATE TABLE cast_crew (
    cast_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    average_rating DECIMAL(3,1)
);

-- 3. Entity 'account'
CREATE TABLE account (
    username VARCHAR(50) PRIMARY KEY NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- 4. Relation 'worked on' (connects movie and cast, adds role attribute)
CREATE TABLE worked_on (
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    cast_id INT NOT NULL,
    PRIMARY KEY (title, release_year, cast_id),
    FOREIGN KEY (title, release_year) REFERENCES movie(title, release_year) ON DELETE CASCADE,
    FOREIGN KEY (cast_id) REFERENCES cast_crew(cast_id) ON DELETE CASCADE
);

-- 5. Relation 'review'
CREATE TABLE review (
    rating DECIMAL(3, 1) NOT NULL,
    CONSTRAINT chk_rating CHECK (rating >= 1.0 AND rating <= 10.0),
    text_content TEXT,
    username VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    PRIMARY KEY (username, title, release_year),
    FOREIGN KEY (username) REFERENCES account(username) ON DELETE CASCADE,
    FOREIGN KEY (title, release_year) REFERENCES movie(title, release_year) ON DELETE CASCADE
); 

-- multi-valued attribute roles on relation worked on
CREATE TABLE roles (
    role_title VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    cast_id INT NOT NULL,
    PRIMARY KEY (role_title, title, release_year, cast_id),
    FOREIGN KEY (title, release_year, cast_id) REFERENCES worked_on(title, release_year, cast_id) ON DELETE CASCADE
);

-- 6. Entity 'genre'
CREATE TABLE genre(
    name VARCHAR(50) PRIMARY KEY
);

-- Relationship 'has genre' (movie<-> genre)
CREATE TABLE movie_genre (
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    genre_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (title, release_year, genre_name),
    FOREIGN KEY (title, release_year) REFERENCES movie(title, release_year) ON DELETE CASCADE,
    FOREIGN KEY (genre_name) REFERENCES genre(name) ON DELETE RESTRICT on UPDATE CASCADE
);

-- GOAL 1 --
DELIMITER //

CREATE TRIGGER update_average_rating
AFTER INSERT ON review
FOR EACH ROW
BEGIN
    UPDATE movie
    SET average_rating = (
    SELECT AVG(rating)
    FROM review
    WHERE review.title = NEW.title
    AND review.release_year = NEW.release_year
    )
    WHERE movie.title = NEW.title
    AND movie.release_year = NEW.release_year;
END //

CREATE TRIGGER update_average_rating_on_update
AFTER UPDATE ON review
FOR EACH ROW
BEGIN
    UPDATE movie
    SET average_rating = (
        SELECT AVG(rating)
        FROM review
        WHERE review.title = NEW.title
        AND review.release_year = NEW.release_year
    )
    WHERE movie.title = NEW.title
    AND movie.release_year = NEW.release_year;
END //

    CREATE TRIGGER update_average_rating_on_delete
AFTER DELETE ON review
FOR EACH ROW
BEGIN
    UPDATE movie
    SET average_rating = (
        SELECT AVG(rating)
        FROM review
        WHERE review.title = OLD.title
        AND review.release_year = OLD.release_year
    )
    WHERE movie.title = OLD.title
    AND movie.release_year = OLD.release_year;
END //
    
DELIMITER ;


INSERT INTO genre (name) VALUES
('Action'), ('Comedy'), ('Drama'), ('Horror'), ('Romance'),
 ('Sci-Fi'), ('Thriller'), ('Western'), ('Fantasy'), ('Mystery'), ('Musical');

-- SAMPLE DATA
INSERT INTO account (username, password) VALUES
('alice', 'pw1'), ('bob', 'pw2'), ('carol', 'pw3'), ('dave', 'pw4'), ('erin', 'pw5'), ('test_ghost_user', 'pw_test');

INSERT INTO movie (title, release_year) VALUES
('Inception', 2010), ('The Godfather', 1972), ('Jaws', 1975),
('Heat', 1995), ('Arrival', 2016);

INSERT INTO movie_genre (title, release_year, genre_name) VALUES
('Inception', 2010, 'Sci-Fi'), 
('Inception', 2010, 'Action'),
('The Godfather', 1972, 'Drama'),
('Jaws', 1975, 'Thriller'),
('Heat', 1995, 'Action'), 
('Heat', 1995, 'Drama'),
('Arrival', 2016, 'Sci-Fi');

INSERT INTO review (rating, text_content, username, title, release_year) VALUES
(8.0, 'Great', 'alice', 'Inception', 2010),
(6.5, 'Good', 'bob', 'Inception', 2010),
(9.0, 'Loved it', 'carol', 'Inception', 2010),
(7.0, 'Solid', 'dave', 'Inception', 2010),
(9.5, 'Masterpiece', 'alice', 'The Godfather', 1972),
(9.0, 'Classic', 'bob', 'The Godfather', 1972),
(10.0, 'Perfect', 'carol', 'The Godfather', 1972),
(8.5, 'Excellent', 'erin', 'The Godfather', 1972),
(7.5, 'Tense', 'bob', 'Jaws', 1975),
(6.0, 'Dated', 'dave', 'Jaws', 1975),
(8.0, 'Iconic', 'erin', 'Jaws', 1975),
(7.0, 'Fun', 'carol', 'Heat', 1995),
(5.5, 'Too long', 'erin', 'Heat', 1995);


-- GOAL 2 --
SELECT 
    m.title,
    m.release_year,
    m.average_rating AS movie_overall_avg,
    FLOOR(r.rating) AS rating_bucket,
    COUNT(*) AS bucket_count,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 1) AS review_percentage
FROM movie m
JOIN review r 
    ON m.title = r.title 
   AND m.release_year = r.release_year
WHERE m.title = 'Inception' 
  AND m.release_year = 2010
GROUP BY m.title, m.release_year, m.average_rating, FLOOR(r.rating)
HAVING COUNT(*) >= 1
ORDER BY rating_bucket ASC;


-- GOAL 3--
EXPLAIN SELECT * FROM movie WHERE release_year = 2010;       --evaluate query before creating index

CREATE INDEX idx_movie_release_year ON movie(release_year);   --create secondary index on release_year

EXPLAIN SELECT * FROM movie WHERE release_year = 2010;        --evaluate query after creating index


-- GOAL 4--
-- First version (complex query)
SELECT m.title, m.release_year
FROM movie m
WHERE (m.title, m.release_year) NOT IN (
    SELECT DISTINCT r.title, r.release_year 
    FROM review r
);

-- Second version (using LEFT JOIN)
SELECT m.title, m.release_year
FROM movie m
LEFT JOIN review r 
    ON m.title = r.title 
   AND m.release_year = r.release_year
WHERE r.rating IS NULL;

-- Additional goals based on the modules covered in the course--

--1. Subquery to aggregate aggregations with conditions --
-- Find the genres with the highest average movie rating among genres that have at least one reviewed movie --
SELECT mg.genre_name, AVG(m.average_rating) AS genre_avg_rating
FROM movie_genre mg
JOIN movie m 
    ON mg.title = m.title AND mg.release_year = m.release_year
WHERE EXISTS (
    SELECT 1 FROM review r 
    WHERE r.title = m.title AND r.release_year = m.release_year
)
GROUP BY mg.genre_name
HAVING AVG(m.average_rating) >= ALL (
    SELECT AVG(m2.average_rating)
    FROM movie_genre mg2
    JOIN movie m2 
        ON mg2.title = m2.title AND mg2.release_year = m2.release_year
    WHERE m2.average_rating IS NOT NULL
    GROUP BY mg2.genre_name
);

-- 2. Complex DML: Delete test accounts that have never submitted a review using NOT EXISTS
DELETE FROM account
WHERE username LIKE 'test_%'
  AND NOT EXISTS (
      SELECT 1 FROM review r 
      WHERE r.username = account.username
  );
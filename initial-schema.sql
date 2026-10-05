-- DATABASE SYSTEMS: PROJECT KICK-OFF --

-- CREATE DATABASE
DROP DATABASE IF EXISTS movie_rating_db;
CREATE DATABASE movie_rating_db;
USE movie_rating_db;

-- 1. Entity 'movie'
CREATE TABLE movie (
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    PRIMARY KEY (title, release_year)
);

-- 2. Entity 'cast'
CREATE TABLE cast_crew (
    id INT PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL
);

-- 3. Entity 'account'
CREATE TABLE account (
    username VARCHAR(50) PRIMARY KEY NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- 4. Relation 'worked on' (connects movie and cast, adds role attribute)
CREATE TABLE worked_on (
    role VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    release_year INT NOT NULL,
    cast_id INT NOT NULL,
    PRIMARY KEY (title, release_year, cast_id, role),
    FOREIGN KEY (title, release_year) REFERENCES movie(title, release_year),
    FOREIGN KEY (cast_id) REFERENCES cast_crew(id)
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
    FOREIGN KEY (username) REFERENCES account(username),
    FOREIGN KEY (title, release_year) REFERENCES movie(title, release_year)
); 

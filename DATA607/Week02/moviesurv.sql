/*
Script: moviesurv
Author: Jai Jeffryes
Date: 9/5/2019

Database platform: MySQL

Purpose:
CUNY DATA607 assignment - SQL and R
Create and populate a database for reading in R.
*/

-- Create database for recording survey of movie ratings.
-- I guess MySQL isn't a multi-database server. The IDE calls
-- this a "schema.".
CREATE DATABASE IF NOT EXISTS `moviesurv`;

/*
Tables
This model could be extended with a table for survey. Then
you could run surveys on different dates with different sets
of movies and respondents. It wouldn't even have to be movies.
You could record respondents' ratings on anything. It would
require more foreign keys and these are harder to populate without
an application or form for it.
*/
CREATE TABLE `moviesurv`.`movie` (
  `movie_id` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`movie_id`));

CREATE TABLE `moviesurv`.`respondent` (
  `respondent_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`respondent_id`));

CREATE TABLE `moviesurv`.`response` (
  `movie_id` INT NOT NULL,
  `respondent_id` INT NOT NULL,
  `response` INT NULL,
  PRIMARY KEY (`movie_id`, `respondent_id`));

-- Populate the tables.
-- Movies
insert into movie(title) values ('Once Upon a Time... in Hollywood');
insert into movie(title) values ('Rocket Man');
insert into movie(title) values ('Green Book');
insert into movie(title) values ('Bohemian Rhapsody');
insert into movie(title) values ('Apollo 11');
insert into movie(title) values ('The Art of Self-Defense');

-- Respondents
insert into respondent(name) values ('Jai');
insert into respondent(name) values ('Jan');
insert into respondent(name) values ('Bob');
insert into respondent(name) values ('Joe');
insert into respondent(name) values ('Lee');

-- Responses
-- Once Upon a Time... in Hollywood
insert into response(movie_id, respondent_id, response) values (1, 1, 3);
insert into response(movie_id, respondent_id, response) values (1, 2, 5);
insert into response(movie_id, respondent_id, response) values (1, 3, null);
insert into response(movie_id, respondent_id, response) values (1, 4, null);
insert into response(movie_id, respondent_id, response) values (1, 5, 4);
-- Rocket Man
insert into response(movie_id, respondent_id, response) values (2, 1, 5);
insert into response(movie_id, respondent_id, response) values (2, 2, 5);
insert into response(movie_id, respondent_id, response) values (2, 3, 4);
insert into response(movie_id, respondent_id, response) values (2, 4, 4);
insert into response(movie_id, respondent_id, response) values (2, 5, null);
-- Green Book
insert into response(movie_id, respondent_id, response) values (3, 1, 4);
insert into response(movie_id, respondent_id, response) values (3, 2, 5);
insert into response(movie_id, respondent_id, response) values (3, 3, 4);
insert into response(movie_id, respondent_id, response) values (3, 4, 3);
insert into response(movie_id, respondent_id, response) values (3, 5, 3);
-- Bohemian Rhapsody
insert into response(movie_id, respondent_id, response) values (4, 1, null);
insert into response(movie_id, respondent_id, response) values (4, 2, 5);
insert into response(movie_id, respondent_id, response) values (4, 3, 4);
insert into response(movie_id, respondent_id, response) values (4, 4, 4);
insert into response(movie_id, respondent_id, response) values (4, 5, 3);
-- Apollo 11
insert into response(movie_id, respondent_id, response) values (5, 1, 4);
insert into response(movie_id, respondent_id, response) values (5, 2, 2);
insert into response(movie_id, respondent_id, response) values (5, 3, 3);
insert into response(movie_id, respondent_id, response) values (5, 4, 3);
insert into response(movie_id, respondent_id, response) values (5, 5, 4);
-- The Art of Self-Defense
insert into response(movie_id, respondent_id, response) values (6, 1, 4);
insert into response(movie_id, respondent_id, response) values (6, 2, 1);
insert into response(movie_id, respondent_id, response) values (6, 3, 5);
insert into response(movie_id, respondent_id, response) values (6, 4, null);
insert into response(movie_id, respondent_id, response) values (6, 5, 4);

/* Working on insert statements
select	*
from	movie;
select	*
from	respondent;
select	*
from	response;
*/

-- Report
select	m.title,
		rsd.name,
        rss.response
from	response rss
join	movie m
on		rss.movie_id = m.movie_id
join	respondent rsd
on		rss.respondent_id = rsd.respondent_id;

select	m.title,
		avg(rss.response) as response_avg
from	response rss
join	movie m
on		rss.movie_id = m.movie_id
group by m.title;

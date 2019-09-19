/*
Script: chess_load.sql
Author: Jai Jeffryes
Date: 9/19/2019

Database platform: MySQL

Purpose:
CUNY DATA607 Project 1 - Chess data load
Create and populate a database for reading in R.
*/

-- Create database for loading chess tournament results
CREATE DATABASE IF NOT EXISTS `chess`;

CREATE TABLE player 
(
  player_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  player_name VARCHAR(1000), 
  state VARCHAR(50), 
  total_points DECIMAL(19,2),
  pre_rating INT,
  opponents_pre_rating DECIMAL(19,2)
);

SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE '/var/lib/mysql-files/player.csv'
	INTO TABLE player;
    
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

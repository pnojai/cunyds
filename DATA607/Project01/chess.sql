/*
Script: chess_load.sql
Author: Jai Jeffryes
Date: 9/19/2019

Database platform: MySQL

Purpose:
CUNY DATA607 Project 1 - Chess data load
Create and populate a database for reading in R.
*/

-- Location for importing files.
-- Returns: /var/lib/mysql-files/
SHOW VARIABLES LIKE "secure_file_priv";

-- Create database for loading chess tournament results
CREATE DATABASE IF NOT EXISTS `chess`;

CREATE TABLE player 
(
  player_name VARCHAR(1000), 
  state VARCHAR(50), 
  total_points DECIMAL(19,2),
  pre_rating INT,
  opponents_pre_rating DECIMAL(19,2)
);

LOAD DATA INFILE '/var/lib/mysql-files/player.csv'
	INTO TABLE player
    COLUMNS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    IGNORE 1 LINES;

select	*
from	player;
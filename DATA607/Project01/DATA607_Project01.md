---
title: "DATA607 Project 1 - Chess Tournament"
author: "Jai Jeffryes"
date: "9/22/2019"
output:
  html_document:
    df_print: paged
    keep_md: true
---


```r
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_knit$set(root.dir = "./../..")

library(data.table) # fread()
library(dplyr) # mutate()
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:data.table':
## 
##     between, first, last
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(stringr)

assign_dir <- "./DATA607/Project01"
assign_data <- paste(assign_dir, "data", sep = "/")
```

## Get data
- Source: [tournamentinfo.txt](https://bbhosted.cuny.edu/bbcswebdav/pid-42267955-dt-content-rid-347468182_1/courses/SPS01_DATA_607_01_1199_1/tournamentinfo.txt)
- Download date: Mon Sep 16 19:21:59 2019

## Functions

```r
split_cols <- function(df, sep) {
	# Reference:
	# https://www.r-bloggers.com/converting-strsplit-output-to-a-data-frame/
	
	# Names for split columns.
	num_cols <- str_count(df[1, ], sep) + 1 # Record ends in trailing separator
	cols <- paste0("split", 1:num_cols)
	
	# Split the records. Unstructured.
	df_tmp <- unlist(str_split(df[ , 1], sep))
	# Pointer for head of each split record
	split_idx <- seq(from = 1, by = num_cols, length = nrow(df))

	# Append split columns.
	# Omit last empty column.
	for (i in 1:(num_cols - 1)) {
		df[, cols[i]] <- df_tmp[split_idx + i -1]
	}
	
	# Return
	df
}

merge_pair_rows <- function(df, col_range_1, col_range_2) {
	df1 <- df[ , col_range_1] %>% filter(row_number() %% 2 == 1)
	names(df1) <- paste0("left_", names(df1))
	df2 <- df[ , col_range_2] %>% filter(row_number() %% 2 == 0)
	names(df2) <- paste0("right_", names(df2))
	
	df_merge <- cbind(df1, df2)
	
	# Return
	df_merge
}

xform <- function(df) {
	# Player number.
	df$player_num_xfm <- as.integer(df$player_number_src)
	# Player name. Format case.
	df$player_name_xfm <- str_to_title(str_trim(df$player_name_src))
	# Points.
	df$points_xfm <- as.numeric(df$points_src)
	# Rounds
	round_col_count <- sum(str_detect(names(df), "round"))
	for (i in 1:round_col_count) {
		# Round result.
		df[ , str_c("round", i, "_result_xfm")] <- 
			str_extract(df[ , paste0("round", i, "_src")], "^\\w")
		# Opponent number
		df[ , str_c("round", i, "_opponent_xfm")] <- 
			str_extract(df[ , paste0("round", i, "_src")], "\\d+")
	}
	# State
	df$state_xfm <- str_trim(df$state_src)
	# USCF ID
	df$uscf_id_xfm <- as.integer(str_extract(str_trim(df$uscf_id_rating_src), "^\\d+"))
	# Rating
	# Rating must be followed by whitespace. Exclude the "P" ratings.
	df$rating_xfm <- as.integer(str_match(df$uscf_id_rating_src, "(R:\\s)(\\d+)\\s")[,3])
	
	#Return
	df
}

read_rounds <- function(df) {
	round_df <- data.frame(
		round <- integer(),
		result <- character(),
		player_num <- integer(),
		opponent_num <- integer(),
		stringsAsFactors = FALSE)
	
	round_count <- sum(str_detect(names(df), "round\\d_result_xfm"))
	
	for (i in 1:round_count) {
			round_row <- df %>%
				select(result = str_c("round", i, "_result_xfm"),
					   player_num = player_num_xfm,
					   opponent_num = str_c("round", i, "_opponent_xfm"))
			# Add round number. Separately because
			# dplyr doesn't select literals.
			round_row <- cbind(round = i, round_row)
			
			round_df <- rbind(round_df, round_row)
	}

	# Return
	round_df
}
```
## Extract, clean/transform

```r
# CONSTANTS
data_fil <- "tournamentinfo.txt"
sep <- "\\|" # Column separator 
data_path <- paste(assign_data, data_fil, sep = "/")
# Columns used.
player_rec1_col_range <- 2:11
player_rec2_col_range <- 2:3

# Read as unstructured text.
chess_raw <- fread(data_path, sep = NULL, header = FALSE)

# Remove column descriptions and separators.
chess_filter_rows_split_cols <- chess_raw %>% 
	filter(row_number() %% 3 != 1 & row_number() > 4)

# Append split columns.
chess_filter_rows_split_cols <- split_cols(df = chess_filter_rows_split_cols, sep = sep)

# Merge row pairs into records
chess_xform <- merge_pair_rows(
	chess_filter_rows_split_cols,
	player_rec1_col_range,
	player_rec2_col_range)

# Name the transformation columns
names(chess_xform) <- c(
	"player_number_src",
	"player_name_src",
	"points_src",
	paste0("round", 1:7, "_src"),
	"state_src",
	"uscf_id_rating_src"
)

# Transform
chess_xform <- xform(chess_xform)
```

## Load

```r
player_df <- data.frame(
	player_num <- integer(),
	player_name = character(),
	total_points = integer(),
	pre_rating = integer(),
	stringsAsFactors = FALSE)

round_df <- data.frame(
	round <- integer(),
	result <- character(),
	player_num <- integer(),
	opponent_num <- integer(),
	stringsAsFactors = FALSE)

player_df <- chess_xform %>%
	select (player_num = player_num_xfm,
			player_name = player_name_xfm,
			total_points = points_xfm,
			pre_rating = rating_xfm)

round_df <- read_rounds(chess_xform)
```

## Processing
### Players

```r
read_player <- function(df, line_num) {
	# Validate input.
	if (line_num %% 2 != 1) {
		stop("Invalid line_num: Player data begins on odd numbered lines")
	}

	# Constants
	line_range <- 2 # Count of lines containing player data.
	
	# Subset raw data for player.
	results <- df[line_num:(line_num + line_range - 1), ]
	results
}

process_player <- function(df) {
	
	
}
```
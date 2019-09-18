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

## Introduction
Project 1 reads chess tournament data, transforms it, and outputs a format that could be loaded into a relational database. The chess tournament data is in a consistent, though unstructured, format, hence the necessity to transform it.

## Requirements
- *Project 1.pdf*. Located in the project's working directory.
- [Reading a Chess Tournament Cross Table](https://www.youtube.com/watch?v=T5PXYl2FEUo). YouTube video with orientation and requirement constraints.

Most of the requirements pertain to reporting data of interest from the chess tournament input file. There is one reporting requirement that adds value to the input data, summarization of opponents' pre-tournament ratings.

Note these exclusions from scope per the YouTube video.

1. Summarization of rounds with results other than a win or a loss.
1. Summarization of pre-tournament ratings with non-numeric characters (e.g. "P").

### Assumptions
For computation of oppenents' average pre-tournament ratings, excluded values reduce the counts. There is no imputation of missing values for out-of-scope rounds or pre-tournament ratings.

## Input data
- Source: [tournamentinfo.txt](https://bbhosted.cuny.edu/bbcswebdav/pid-42267955-dt-content-rid-347468182_1/courses/SPS01_DATA_607_01_1199_1/tournamentinfo.txt)
- Download date: Mon Sep 16 19:21:59 2019
- Location for processing: ./DATA607/Project01/data.

## Functions
- `split_cols()`. Athough the input file delimits data, it also contains non-data visual separating rows. Therefore, file reading functions within base R are unable to split the columns. This function assumes deletion of the separator rows and splits on a column separator. It preserves the raw data and appends to it the split columns.
- `merge_pair_rows()`. Player data is recorded in two rows. The formats of the two rows are different from each other, while remaining consistent from player to player. This function arranges each player's two rows side-by-side, forming a single record per player.
- `xform()`. Transforms the raw data. Data types are coerced where necessary. Out-of-scope ratings are left unmapped. The functions supports flexibility in the input of data for rounds. Any number of rounds can be included.
- `read_rounds()`. The input file records tournament round results in a cross tab format. This function pivots the rounds into a Tidy format for aggregation and reporting. The function supports input of files with any number of rounds.

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
	# State.
	df$state_xfm <- str_trim(df$state_src)
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
			as.integer(str_extract(df[ , paste0("round", i, "_src")], "\\d+"))
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
		result_col_idx <- which(names(df) == str_c("round", i, "_result_xfm"))
		opponent_col_idx <- which(names(df) == str_c("round", i, "_opponent_xfm"))
		
		round_row <- df %>%
			select(result = result_col_idx,
				   player_num = player_num_xfm,
				   opponent_num = opponent_col_idx)
		# Add round number separately because
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
# Define PLAYER data frame.
player_df <- data.frame(
	player_num <- integer(),
	player_name = character(),
	state = character(),
	total_points = integer(),
	pre_rating = integer(),
	stringsAsFactors = FALSE)

# Define ROUND data frame.
round_df <- data.frame(
	round <- integer(),
	result <- character(),
	player_num <- integer(),
	opponent_num <- integer(),
	stringsAsFactors = FALSE)

# Load PLAYER data frame.
player_df <- chess_xform %>%
	select (player_num = player_num_xfm,
			player_name = player_name_xfm,
			state = state_xfm,
			total_points = points_xfm,
			pre_rating = rating_xfm)

# Load ROUND data frame.
round_df <- read_rounds(chess_xform)
```

## Summarize

```r
# Question: Is there a single-pass way to add the summary column to player_df, perhaps using mutate()?
opponent_prerating_df <- 
	inner_join(x = round_df, y = player_df, by = c("opponent_num" = "player_num")) %>%
	filter(!is.na(pre_rating)) %>%
	group_by(player_num) %>%
	summarize(opponents_pre_rating = mean(pre_rating)) 

player_df <- inner_join(x = player_df, y = opponent_prerating_df)
```

```
## Joining, by = "player_num"
```

```r
rm(opponent_prerating_df)
```

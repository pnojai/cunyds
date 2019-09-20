---
title: "DATA607 Project 1 - Chess Tournament"
author: "Jai Jeffryes"
date: "9/20/2019"
output:
  html_document:
    df_print: paged
    keep_md: true
---


```r
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_knit$set(root.dir = "./../..")

library(data.table) # fread()
library(dplyr)
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
library(RMySQL)
```

```
## Loading required package: DBI
```

```r
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
- For computation of oppenents' average pre-tournament ratings, excluded values reduce the counts. There is no imputation of missing values for out-of-scope rounds or pre-tournament ratings.
- The number of rounds in a tournment are variable.

## Input
- Source data: [tournamentinfo.txt](https://bbhosted.cuny.edu/bbcswebdav/pid-42267955-dt-content-rid-347468182_1/courses/SPS01_DATA_607_01_1199_1/tournamentinfo.txt)
- Download date: Mon Sep 16 19:21:59 2019
- Location for processing: ./DATA607/Project01/data.

## Output and report
Data processing produces a list of data frames. The name of the list is created at run time. Depositing the output into a list permits processing of multiple input files and retaining their output separately. These lists may be viewed by sourcing this R Markdown file in RStudio.

The output list contains these data frames:

- `chess_raw`. Raw data from the input file. No cleansing.
- `chess_split`. Cleansing has started. Header rows and separator rows are removed. Fields of the data rows are split by the delimiter.
- `chess_xform`. The input file format allots two rows for each player. This data frame reorganizes them  side by side into a single row for each player. Names are applied to columns. The source columns from `chess_split` are retained. Transformations are applied to transformation columns in the same row.
- `player_df`. Reporting table for players. The average pre-rating for a player's opponents is computed and appended to this table.
- `round_df`. Reporting table for chess round results, organized in a Tidy format.

The required CSV report is built from the data frame, `player_df` and sampled below. The location of the file is: ./DATA607/Project01/player.csv.

## Functions
- `split_cols()`. Athough the input file delimits data, it also contains non-data visual separating rows. Therefore, file reading functions within base R are unable to split the columns. This function assumes deletion of the separator rows and splits on a column separator. It preserves the raw data in the first column and appends the split columns.
- `merge_player_rows()`. Player data is recorded in two rows. The formats of the two rows are different from each other, while remaining consistent from player to player. This function arranges each player's two rows side-by-side, forming a single record per player.
- `xform_data()`. Transforms the raw data. Data types are coerced where necessary. Out-of-scope ratings are left unmapped. The function supports flexibility in tournament rounds. Any number of rounds can be included in the input file.
- `read_rounds()`. The input file records tournament round results in a cross tab format. This function pivots the rounds into a Tidy format for aggregation and reporting. The function supports input of files with any number of rounds.
- `process_file()`.
  - Reads data file. Probes it for the number of rounds.
  - Begins data cleansing.
  - Calls function to split columns.
  - Calls function to transform columns.

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

merge_player_rows <- function(df, col_range_1, col_range_2) {
	df1 <- df[ , col_range_1] %>% filter(row_number() %% 2 == 1)
	names(df1) <- paste0("left_", names(df1))
	df2 <- df[ , col_range_2] %>% filter(row_number() %% 2 == 0)
	names(df2) <- paste0("right_", names(df2))
	
	df_merge <- cbind(df1, df2)
	
	# Return
	df_merge
}

xform_data <- function(df) {
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
	
	round_count <- sum(str_detect(names(df), "round\\d+_result_xfm"))
	
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

process_file <- function(dat_file) {
	# CONSTANTS
	sep <- "\\|" # Column separator 

	out <- list() # Output multiple data frames
	
	# Read as unstructured text.
	out$chess_raw <- fread(dat_file, sep = NULL, header = FALSE)
	
	# Count rounds
	# Headings are in row 2 of the raw data.
	round_count <- str_count(toupper(out$chess_raw[2, 1]), "ROUND")
	
	# Columns used in each record type.
	player_rec1_col_range <- 2:(4 + round_count)
	player_rec2_col_range <- 2:3
	
	# Remove column descriptions and separators.
	out$chess_split <- out$chess_raw %>% 
		filter(row_number() %% 3 != 1 & row_number() > 4)
	
	# Append split columns.
	out$chess_split <- split_cols(df = out$chess_split, sep = sep)
	
	# Merge row pairs into records
	out$chess_xform <- merge_player_rows(
		out$chess_split,
		player_rec1_col_range,
		player_rec2_col_range)
	
	# Name the transformation columns
	names(out$chess_xform) <- c(
		"player_number_src",
		"player_name_src",
		"points_src",
		paste0("round", 1:round_count, "_src"),
		"state_src",
		"uscf_id_rating_src"
	)
	
	# Transform
	out$chess_xform <- xform_data(out$chess_xform)

	return(out)
}

load_data <- function(dat_list) {
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
	
	chess_xfm <- dat_list[[3]] # Lists passed as parameters don't always allow reference by element name.
							   # dat_list$chess_xfm didn't work here.
	
	player_df <- chess_xfm %>%
		select (player_num = player_num_xfm,
				player_name = player_name_xfm,
				state = state_xfm,
				total_points = points_xfm,
				pre_rating = rating_xfm)
	dat_list$player_df <- player_df

	# Load ROUND data frame.
	round_df <- read_rounds(chess_xfm)
	dat_list$round_df <- round_df
	
	return(dat_list)
}

append_summaries <- function(dat_list) {
	round_df <- dat_list[[5]]
	player_df <- dat_list[[4]]
	
	# Question: Is there a single-pass way to add the summary column to player_df, perhaps using mutate()?
	opponent_prerating_df <- 
		inner_join(x = round_df, y = player_df, by = c("opponent_num" = "player_num")) %>%
		filter(!is.na(pre_rating)) %>%
		group_by(player_num) %>%
		summarize(opponents_pre_rating = mean(pre_rating)) 
	
	player_df <- inner_join(x = player_df, y = opponent_prerating_df)
	
	dat_list$player_df <- player_df

	return(dat_list)	
}
```
## Process and load

```r
dat_file_name <- "tournamentinfo.txt"
# Fully qualified path.
dat_file <- paste(assign_data, dat_file_name, sep = "/")

# Process
tournamentinfo_list <- process_file(dat_file)

# Load 
tournamentinfo_list <- load_data(tournamentinfo_list)

# Append summaries
tournamentinfo_list <- append_summaries(tournamentinfo_list)
```

```
## Joining, by = "player_num"
```
## Inspect results
The output is lengthy, so you may [Jump forward to the report](#report).

```r
# Data frames in the list
names(tournamentinfo_list)
```

```
## [1] "chess_raw"   "chess_split" "chess_xform" "player_df"   "round_df"
```

```r
# Top of each data frame
lapply(tournamentinfo_list, print(head))
```

```
## function (x, ...) 
## UseMethod("head")
## <bytecode: 0x55df1f3ac708>
## <environment: namespace:utils>
```

```
## $chess_raw
##                                                                                           V1
## 1: -----------------------------------------------------------------------------------------
## 2:  Pair | Player Name                     |Total|Round|Round|Round|Round|Round|Round|Round|
## 3:  Num  | USCF ID / Rtg (Pre->Post)       | Pts |  1  |  2  |  3  |  4  |  5  |  6  |  7  |
## 4: -----------------------------------------------------------------------------------------
## 5:     1 | GARY HUA                        |6.0  |W  39|W  21|W  18|W  14|W   7|D  12|D   4|
## 6:    ON | 15445895 / R: 1794   ->1817     |N:2  |W    |B    |W    |B    |W    |B    |W    |
## 
## $chess_split
##                                                                                       V1
## 1  1 | GARY HUA                        |6.0  |W  39|W  21|W  18|W  14|W   7|D  12|D   4|
## 2 ON | 15445895 / R: 1794   ->1817     |N:2  |W    |B    |W    |B    |W    |B    |W    |
## 3  2 | DAKSHESH DARURI                 |6.0  |W  63|W  58|L   4|W  17|W  16|W  20|W   7|
## 4 MI | 14598900 / R: 1553   ->1663     |N:2  |B    |W    |B    |W    |B    |W    |B    |
## 5  3 | ADITYA BAJAJ                    |6.0  |L   8|W  61|W  25|W  21|W  11|W  13|W  12|
## 6 MI | 14959604 / R: 1384   ->1640     |N:2  |W    |B    |W    |B    |W    |B    |W    |
##   split1                            split2 split3 split4 split5 split6
## 1     1   GARY HUA                          6.0    W  39  W  21  W  18
## 2    ON   15445895 / R: 1794   ->1817       N:2    W      B      W    
## 3     2   DAKSHESH DARURI                   6.0    W  63  W  58  L   4
## 4    MI   14598900 / R: 1553   ->1663       N:2    B      W      B    
## 5     3   ADITYA BAJAJ                      6.0    L   8  W  61  W  25
## 6    MI   14959604 / R: 1384   ->1640       N:2    W      B      W    
##   split7 split8 split9 split10
## 1  W  14  W   7  D  12   D   4
## 2  B      W      B       W    
## 3  W  17  W  16  W  20   W   7
## 4  W      B      W       B    
## 5  W  21  W  11  W  13   W  12
## 6  B      W      B       W    
## 
## $chess_xform
##   player_number_src                   player_name_src points_src
## 1                1   GARY HUA                              6.0  
## 2                2   DAKSHESH DARURI                       6.0  
## 3                3   ADITYA BAJAJ                          6.0  
## 4                4   PATRICK H SCHILLING                   5.5  
## 5                5   HANSHI ZUO                            5.5  
## 6                6   HANSEN SONG                           5.0  
##   round1_src round2_src round3_src round4_src round5_src round6_src
## 1      W  39      W  21      W  18      W  14      W   7      D  12
## 2      W  63      W  58      L   4      W  17      W  16      W  20
## 3      L   8      W  61      W  25      W  21      W  11      W  13
## 4      W  23      D  28      W   2      W  26      D   5      W  19
## 5      W  45      W  37      D  12      D  13      D   4      W  14
## 6      W  34      D  29      L  11      W  35      D  10      W  27
##   round7_src state_src                uscf_id_rating_src player_num_xfm
## 1      D   4       ON   15445895 / R: 1794   ->1817                   1
## 2      W   7       MI   14598900 / R: 1553   ->1663                   2
## 3      W  12       MI   14959604 / R: 1384   ->1640                   3
## 4      D   1       MI   12616049 / R: 1716   ->1744                   4
## 5      W  17       MI   14601533 / R: 1655   ->1690                   5
## 6      W  21       OH   15055204 / R: 1686   ->1687                   6
##       player_name_xfm state_xfm points_xfm round1_result_xfm
## 1            Gary Hua        ON        6.0                 W
## 2     Dakshesh Daruri        MI        6.0                 W
## 3        Aditya Bajaj        MI        6.0                 L
## 4 Patrick H Schilling        MI        5.5                 W
## 5          Hanshi Zuo        MI        5.5                 W
## 6         Hansen Song        OH        5.0                 W
##   round1_opponent_xfm round2_result_xfm round2_opponent_xfm
## 1                  39                 W                  21
## 2                  63                 W                  58
## 3                   8                 W                  61
## 4                  23                 D                  28
## 5                  45                 W                  37
## 6                  34                 D                  29
##   round3_result_xfm round3_opponent_xfm round4_result_xfm
## 1                 W                  18                 W
## 2                 L                   4                 W
## 3                 W                  25                 W
## 4                 W                   2                 W
## 5                 D                  12                 D
## 6                 L                  11                 W
##   round4_opponent_xfm round5_result_xfm round5_opponent_xfm
## 1                  14                 W                   7
## 2                  17                 W                  16
## 3                  21                 W                  11
## 4                  26                 D                   5
## 5                  13                 D                   4
## 6                  35                 D                  10
##   round6_result_xfm round6_opponent_xfm round7_result_xfm
## 1                 D                  12                 D
## 2                 W                  20                 W
## 3                 W                  13                 W
## 4                 W                  19                 D
## 5                 W                  14                 W
## 6                 W                  27                 W
##   round7_opponent_xfm uscf_id_xfm rating_xfm
## 1                   4    15445895       1794
## 2                   7    14598900       1553
## 3                  12    14959604       1384
## 4                   1    12616049       1716
## 5                  17    14601533       1655
## 6                  21    15055204       1686
## 
## $player_df
##   player_num         player_name state total_points pre_rating
## 1          1            Gary Hua    ON          6.0       1794
## 2          2     Dakshesh Daruri    MI          6.0       1553
## 3          3        Aditya Bajaj    MI          6.0       1384
## 4          4 Patrick H Schilling    MI          5.5       1716
## 5          5          Hanshi Zuo    MI          5.5       1655
## 6          6         Hansen Song    OH          5.0       1686
##   opponents_pre_rating
## 1             1647.600
## 2             1561.333
## 3             1696.500
## 4             1573.571
## 5             1587.667
## 6             1493.200
## 
## $round_df
##   round result player_num opponent_num
## 1     1      W          1           39
## 2     1      W          2           63
## 3     1      L          3            8
## 4     1      W          4           23
## 5     1      W          5           45
## 6     1      W          6           34
```

## Report

```r
# Output the file.
player_file <- paste(assign_dir, "player.csv", sep = "/")
write.csv(tournamentinfo_list$player_df[ , -1], player_file, row.names = FALSE, na = "\\N")
```
Location of output file: ./DATA607/Project01/player.csv

The requirements specify the format for outputting a CSV file.

- Note that the specification omits the player number.
- NULL values are encoded as "\\N". This is a requirement of MySQL, followed here to satisfy the project's requirement to support loading a database. I discuss MySQL further in the section, [Test loading MySQL](#test-loading-mysql) within the Supplements section.
- The opponents' pre-rating differs from the expected results as documented in the project requirements due to modification of scope by the YouTube video, which excludes rounds ending in other than a win or a loss.


```r
# Inspect the file
report <- read.csv(player_file)
head(report)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["player_name"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["state"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["total_points"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["pre_rating"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["opponents_pre_rating"],"name":[5],"type":["dbl"],"align":["right"]}],"data":[{"1":"Gary Hua","2":"ON","3":"6.0","4":"1794","5":"1647.600","_rn_":"1"},{"1":"Dakshesh Daruri","2":"MI","3":"6.0","4":"1553","5":"1561.333","_rn_":"2"},{"1":"Aditya Bajaj","2":"MI","3":"6.0","4":"1384","5":"1696.500","_rn_":"3"},{"1":"Patrick H Schilling","2":"MI","3":"5.5","4":"1716","5":"1573.571","_rn_":"4"},{"1":"Hanshi Zuo","2":"MI","3":"5.5","4":"1655","5":"1587.667","_rn_":"5"},{"1":"Hansen Song","2":"OH","3":"5.0","4":"1686","5":"1493.200","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

## Supplements
### Test loading MySQL
Script for loading player data to MySQL: `chess.sql`.

In a previous assignment about MySQL, the grader challenged me to learn how to populate tables without relying on `INSERT` statements. The current project was an opportunity to do that, and though loading a database was not an explicit requirement for this project, the objective was to produce a CSV file that could be loaded. Therefore, it was worth testing.

#### Report results

```r
con <- dbConnect(
	drv = MySQL(),
	host = "127.0.0.1",
	user = "jairpt",
	password = "a",
	dbname = "chess")

sql <- "
select	*
from	player;"

player <- dbGetQuery(con, sql)
```

```
## Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as
## numeric
```

```
## Warning in .local(conn, statement, ...): Decimal MySQL column 4 imported as
## numeric
```

```r
print(head(player))
```

```
##           player_name state total_points pre_rating opponents_pre_rating
## 1            Gary Hua    ON          6.0       1794              1647.60
## 2     Dakshesh Daruri    MI          6.0       1553              1561.33
## 3        Aditya Bajaj    MI          6.0       1384              1696.50
## 4 Patrick H Schilling    MI          5.5       1716              1573.57
## 5          Hanshi Zuo    MI          5.5       1655              1587.67
## 6         Hansen Song    OH          5.0       1686              1493.20
```

#### Lessons learned
- Loading text files into MySQL relies on the `LOAD DATA` scripting command. [Link to Documentation](https://dev.mysql.com/doc/refman/8.0/en/load-data.html)
- The security design of MySQL bounds data loads. Online discussion appears to focus on ways to "work around" this constraint. However, this limitation is a design feature, not a bug, and here I focus on complying with the security design.
  - Files for loading must be deposited in a specific system directory intended for that purpose. Query for the location by running the command, `SHOW VARIABLES LIKE "secure_file_priv";`.
  - The user must have the database privilege, `FILE`, in order to run `LOAD DATA`.
  - Even if the file is in the correct location, the Linux OS allows the `LOAD DATA` command access to it only if the file is owned by the group, `mysql`, and the user, `mysql`. Otherwise, the `LOAD DATA` command raises the error *"OS errno 13 - Permission denied."* This is an operating system error, not a MySQL one. Thefore, after copying an input file to the secure directory, it is necessary to change the file's group and user ownership. Terminal in as root with `sudo -i`. Then execute, for example, `chown mysql:mysql player.csv`.
- Loading NULL values to databases is platform specific. MySQL specifies `\N` for representing NULL values in input data files intended for `LOAD DATA`. It loads empty strings as `''` rather than NULL, contrary to Microsoft SQL Server.

### Test additional rounds
The format for chess tournament data is a cross tab report. An assumption for this project is tournaments are not limited to seven rounds. Therefore, I designed the load to be flexible for round count.

#### Test approach
I prepared another test file by duplicating all the rounds using Emacs. Since the data file employs a fixed width format, a macro was able to append to each line. The macro advanced 47 characters into a line to the first position of the first round. It copied to the end of the line, and pasted (yanked, in Emacs terms). I modified the round numbers in the heading, although the load process disregards them in any case.

I processed the test file using code identical to processing the original data file, but specifying a different input file name and a different list for output. The design employing output to a list of data frames serves here to support processing of multiple files and retention of their results.

Expected results:

- The process completes successfully with no run time errors.
- The opponents' pre-rating averages are the same as the first load, since I duplicated the rounds.


```r
dat_file_name <- "tournamenttest.txt"
# Fully qualified path.
dat_file <- paste(assign_data, dat_file_name, sep = "/")

# Process
tournamenttest_list <- process_file(dat_file)

# Load 
tournamenttest_list <- load_data(tournamenttest_list)

# Append summaries
tournamenttest_list <- append_summaries(tournamenttest_list)
```

```
## Joining, by = "player_num"
```
#### Test results
The list, `tournamenttest_list`, is returned. Here is the top of each list. Note there are 14 rounds. The output is lengthy, so you may [jump forward to the comparison](#compare-results).

```r
# Top of each data frame
lapply(tournamenttest_list, print(head))
```

```
## function (x, ...) 
## UseMethod("head")
## <bytecode: 0x55df1f3ac708>
## <environment: namespace:utils>
```

```
## $chess_raw
##                                                                                                                                     V1
## 1: -----------------------------------------------------------------------------------------------------------------------------------
## 2:  Pair | Player Name                     |Total|Round|Round|Round|Round|Round|Round|Round|Round|Round|Round|Round|Round|Round|Round|
## 3:  Num  | USCF ID / Rtg (Pre->Post)       | Pts |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  | 10  | 11  | 12  | 13  | 14  |
## 4: -----------------------------------------------------------------------------------------------------------------------------------
## 5:     1 | GARY HUA                        |6.0  |W  39|W  21|W  18|W  14|W   7|D  12|D   4|W  39|W  21|W  18|W  14|W   7|D  12|D   4|
## 6:    ON | 15445895 / R: 1794   ->1817     |N:2  |W    |B    |W    |B    |W    |B    |W    |W    |B    |W    |B    |W    |B    |W    |
## 
## $chess_split
##                                                                                                                                 V1
## 1  1 | GARY HUA                        |6.0  |W  39|W  21|W  18|W  14|W   7|D  12|D   4|W  39|W  21|W  18|W  14|W   7|D  12|D   4|
## 2 ON | 15445895 / R: 1794   ->1817     |N:2  |W    |B    |W    |B    |W    |B    |W    |W    |B    |W    |B    |W    |B    |W    |
## 3  2 | DAKSHESH DARURI                 |6.0  |W  63|W  58|L   4|W  17|W  16|W  20|W   7|W  63|W  58|L   4|W  17|W  16|W  20|W   7|
## 4 MI | 14598900 / R: 1553   ->1663     |N:2  |B    |W    |B    |W    |B    |W    |B    |B    |W    |B    |W    |B    |W    |B    |
## 5  3 | ADITYA BAJAJ                    |6.0  |L   8|W  61|W  25|W  21|W  11|W  13|W  12|L   8|W  61|W  25|W  21|W  11|W  13|W  12|
## 6 MI | 14959604 / R: 1384   ->1640     |N:2  |W    |B    |W    |B    |W    |B    |W    |W    |B    |W    |B    |W    |B    |W    |
##   split1                            split2 split3 split4 split5 split6
## 1     1   GARY HUA                          6.0    W  39  W  21  W  18
## 2    ON   15445895 / R: 1794   ->1817       N:2    W      B      W    
## 3     2   DAKSHESH DARURI                   6.0    W  63  W  58  L   4
## 4    MI   14598900 / R: 1553   ->1663       N:2    B      W      B    
## 5     3   ADITYA BAJAJ                      6.0    L   8  W  61  W  25
## 6    MI   14959604 / R: 1384   ->1640       N:2    W      B      W    
##   split7 split8 split9 split10 split11 split12 split13 split14 split15
## 1  W  14  W   7  D  12   D   4   W  39   W  21   W  18   W  14   W   7
## 2  B      W      B       W       W       B       W       B       W    
## 3  W  17  W  16  W  20   W   7   W  63   W  58   L   4   W  17   W  16
## 4  W      B      W       B       B       W       B       W       B    
## 5  W  21  W  11  W  13   W  12   L   8   W  61   W  25   W  21   W  11
## 6  B      W      B       W       W       B       W       B       W    
##   split16 split17
## 1   D  12   D   4
## 2   B       W    
## 3   W  20   W   7
## 4   W       B    
## 5   W  13   W  12
## 6   B       W    
## 
## $chess_xform
##   player_number_src                   player_name_src points_src
## 1                1   GARY HUA                              6.0  
## 2                2   DAKSHESH DARURI                       6.0  
## 3                3   ADITYA BAJAJ                          6.0  
## 4                4   PATRICK H SCHILLING                   5.5  
## 5                5   HANSHI ZUO                            5.5  
## 6                6   HANSEN SONG                           5.0  
##   round1_src round2_src round3_src round4_src round5_src round6_src
## 1      W  39      W  21      W  18      W  14      W   7      D  12
## 2      W  63      W  58      L   4      W  17      W  16      W  20
## 3      L   8      W  61      W  25      W  21      W  11      W  13
## 4      W  23      D  28      W   2      W  26      D   5      W  19
## 5      W  45      W  37      D  12      D  13      D   4      W  14
## 6      W  34      D  29      L  11      W  35      D  10      W  27
##   round7_src round8_src round9_src round10_src round11_src round12_src
## 1      D   4      W  39      W  21       W  18       W  14       W   7
## 2      W   7      W  63      W  58       L   4       W  17       W  16
## 3      W  12      L   8      W  61       W  25       W  21       W  11
## 4      D   1      W  23      D  28       W   2       W  26       D   5
## 5      W  17      W  45      W  37       D  12       D  13       D   4
## 6      W  21      W  34      D  29       L  11       W  35       D  10
##   round13_src round14_src state_src                uscf_id_rating_src
## 1       D  12       D   4       ON   15445895 / R: 1794   ->1817     
## 2       W  20       W   7       MI   14598900 / R: 1553   ->1663     
## 3       W  13       W  12       MI   14959604 / R: 1384   ->1640     
## 4       W  19       D   1       MI   12616049 / R: 1716   ->1744     
## 5       W  14       W  17       MI   14601533 / R: 1655   ->1690     
## 6       W  27       W  21       OH   15055204 / R: 1686   ->1687     
##   player_num_xfm     player_name_xfm state_xfm points_xfm
## 1              1            Gary Hua        ON        6.0
## 2              2     Dakshesh Daruri        MI        6.0
## 3              3        Aditya Bajaj        MI        6.0
## 4              4 Patrick H Schilling        MI        5.5
## 5              5          Hanshi Zuo        MI        5.5
## 6              6         Hansen Song        OH        5.0
##   round1_result_xfm round1_opponent_xfm round2_result_xfm
## 1                 W                  39                 W
## 2                 W                  63                 W
## 3                 L                   8                 W
## 4                 W                  23                 D
## 5                 W                  45                 W
## 6                 W                  34                 D
##   round2_opponent_xfm round3_result_xfm round3_opponent_xfm
## 1                  21                 W                  18
## 2                  58                 L                   4
## 3                  61                 W                  25
## 4                  28                 W                   2
## 5                  37                 D                  12
## 6                  29                 L                  11
##   round4_result_xfm round4_opponent_xfm round5_result_xfm
## 1                 W                  14                 W
## 2                 W                  17                 W
## 3                 W                  21                 W
## 4                 W                  26                 D
## 5                 D                  13                 D
## 6                 W                  35                 D
##   round5_opponent_xfm round6_result_xfm round6_opponent_xfm
## 1                   7                 D                  12
## 2                  16                 W                  20
## 3                  11                 W                  13
## 4                   5                 W                  19
## 5                   4                 W                  14
## 6                  10                 W                  27
##   round7_result_xfm round7_opponent_xfm round8_result_xfm
## 1                 D                   4                 W
## 2                 W                   7                 W
## 3                 W                  12                 L
## 4                 D                   1                 W
## 5                 W                  17                 W
## 6                 W                  21                 W
##   round8_opponent_xfm round9_result_xfm round9_opponent_xfm
## 1                  39                 W                  21
## 2                  63                 W                  58
## 3                   8                 W                  61
## 4                  23                 D                  28
## 5                  45                 W                  37
## 6                  34                 D                  29
##   round10_result_xfm round10_opponent_xfm round11_result_xfm
## 1                  W                   18                  W
## 2                  L                    4                  W
## 3                  W                   25                  W
## 4                  W                    2                  W
## 5                  D                   12                  D
## 6                  L                   11                  W
##   round11_opponent_xfm round12_result_xfm round12_opponent_xfm
## 1                   14                  W                    7
## 2                   17                  W                   16
## 3                   21                  W                   11
## 4                   26                  D                    5
## 5                   13                  D                    4
## 6                   35                  D                   10
##   round13_result_xfm round13_opponent_xfm round14_result_xfm
## 1                  D                   12                  D
## 2                  W                   20                  W
## 3                  W                   13                  W
## 4                  W                   19                  D
## 5                  W                   14                  W
## 6                  W                   27                  W
##   round14_opponent_xfm uscf_id_xfm rating_xfm
## 1                    4    15445895       1794
## 2                    7    14598900       1553
## 3                   12    14959604       1384
## 4                    1    12616049       1716
## 5                   17    14601533       1655
## 6                   21    15055204       1686
## 
## $player_df
##   player_num         player_name state total_points pre_rating
## 1          1            Gary Hua    ON          6.0       1794
## 2          2     Dakshesh Daruri    MI          6.0       1553
## 3          3        Aditya Bajaj    MI          6.0       1384
## 4          4 Patrick H Schilling    MI          5.5       1716
## 5          5          Hanshi Zuo    MI          5.5       1655
## 6          6         Hansen Song    OH          5.0       1686
##   opponents_pre_rating
## 1             1647.600
## 2             1561.333
## 3             1696.500
## 4             1573.571
## 5             1587.667
## 6             1493.200
## 
## $round_df
##   round result player_num opponent_num
## 1     1      W          1           39
## 2     1      W          2           63
## 3     1      L          3            8
## 4     1      W          4           23
## 5     1      W          5           45
## 6     1      W          6           34
```

##### Compare results
Compare the opponents' pre-rating in the data_frame, `player_df`.

```r
print(head(tournamentinfo_list$player_df[ , c("player_name", "opponents_pre_rating")]))
```

```
##           player_name opponents_pre_rating
## 1            Gary Hua             1647.600
## 2     Dakshesh Daruri             1561.333
## 3        Aditya Bajaj             1696.500
## 4 Patrick H Schilling             1573.571
## 5          Hanshi Zuo             1587.667
## 6         Hansen Song             1493.200
```

```r
print(head(tournamenttest_list$player_df[ , c("player_name", "opponents_pre_rating")]))
```

```
##           player_name opponents_pre_rating
## 1            Gary Hua             1647.600
## 2     Dakshesh Daruri             1561.333
## 3        Aditya Bajaj             1696.500
## 4 Patrick H Schilling             1573.571
## 5          Hanshi Zuo             1587.667
## 6         Hansen Song             1493.200
```
#### Debugging
My first test cycle failed. Some players' averages of opponents' pre-ratings did not match between the original file and the test file. The experience demonstrated the value of retaining each stage of data manipulation in lists, which enabled me to trace data lineage and locate the source of the bug. The transformed data was correct, but extracting the rounds to round_df omitted some rows. The bug was in the function, `read_rounds()`, which uses a Regular Expression to count the columns for rounds. The expression failed to match for multiple digits, so the most rounds it could include was 9.

My debugging work appears in `debug.R`. Executing the script yields different results now, since I fixed the bug, but the script documents my investigative approach.

#### Conclusion
The test for processing addition rounds succeeds. I base the conclusion on a visual inspection of the top records. A complete test cycle would validate all records.

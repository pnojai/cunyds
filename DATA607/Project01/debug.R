# Issue: Opponents' pre-rating differ between original data and test.
# Player 2: 1561.333 and 1506.143
head(tournamentinfo_list$player_df)
head(tournamenttest_list$player_df)

# Round counts. 7 in the first. Should be 14 in second
# but only 9.
subset(tournamentinfo_list$round_df, player_num == 2)
subset(tournamenttest_list$round_df, player_num == 2)

# Trace backwards. Did all rounds make it into the transformation
# table? Yes.
names(tournamentinfo_list$chess_xform)
names(tournamenttest_list$chess_xform)

# Compare the values.
# Are rounds 1-7 identical between the datasets? Yes.
# Are rounds 8-14 identical to 1-7 in the second dataset? Yes.
subset(tournamentinfo_list$chess_xform, player_num_xfm == 2)[, 17:30]
subset(tournamenttest_list$chess_xform, player_num_xfm == 2)[, 24:51]

# Inspect how round_df is populated. Compare results of functions calls.
# Here is the bug. Original data returns 6 rows, test returns 9 instead of 12.
subset(read_rounds(tournamentinfo_list[[3]]), player_num == 2)
subset(read_rounds(tournamenttest_list[[3]]), player_num == 2)

# Hypothesis: Observed that round counts in test stop at 9.
# Maybe the dynamic column names can handle two digits in the
# round number.
# Here's the line for counting rounds:
# round_count <- sum(str_detect(names(df), "round\\d_result_xfm"))
# The RegEx lacks a match for multiple digits in a number.
sum(str_detect(names(tournamentinfo_list$chess_xform), "round\\d_result_xfm"))
sum(str_detect(names(tournamenttest_list$chess_xform), "round\\d_result_xfm"))
# Fix returns 14, as expected.
sum(str_detect(names(tournamenttest_list$chess_xform), "round\\d+_result_xfm"))

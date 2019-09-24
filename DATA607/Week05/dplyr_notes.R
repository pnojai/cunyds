df <- tournamentinfo_list$chess_xform
df <- tbl_df(df)
head(df)
df
df %>% select(everything())
df %>% select(contains("round"))
df %>% select(ends_with("xfm"))
df %>% # string literals
	mutate(string_literal = "fnord") %>%
	select(player_name_xfm, string_literal)

# type %>% with Ctrl-shift_m.
# %>% %>% %>% %>% %>% 

df %>%
	group_by(points_xfm) %>% 
	summarize(n = n())

select(df, n())

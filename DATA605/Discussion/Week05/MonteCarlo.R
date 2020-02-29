MonteCarlo <- function(trials) {
	x <- runif(trials, min = 0, max = 1)
	y <- runif(trials, min = 0, max = 1)
	
	is_under_curve <- sum(y <= x^2)
	area <- is_under_curve / trials
	return(area)
}
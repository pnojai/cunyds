## R code 8.1
num_weeks <- 1e5
positions <- rep(0,num_weeks)
current <- 10
for ( i in 1:num_weeks ) {
	# record current position
	positions[i] <- current
	
	# flip coin to generate proposal
	proposal <- current + sample( c(-1,1) , size=1 )
	# now make sure he loops around the archipelago
	if ( proposal < 1 ) proposal <- 10
	if ( proposal > 10 ) proposal <- 1
	
	# move?
	prob_move <- proposal/current
	current <- ifelse( runif(1) < prob_move , proposal , current )
}

positions_tbl <- table(positions)

head(positions_tbl)

library(pracma)
A <- matrix( c(5, 1, 0,
			   3,-1, 2,
			   4, 0,-1), nrow=3, byrow=TRUE)
det(A)
(AI  <- inv(A))
Q <- matrix(c(
	0, .5, 0,
	.5, 0, .5,
	0, .5, 0),
	nrow = 3, byrow = T)

diag(3) - Q
inv(diag(3) - Q)

P <- matrix(c(
	0, 1, 0, 0, 0,
	.25, 0, .75, 0, 0,
	0, .5, 0, .5, 0,
	0, 0, .75, 0, .25,
	0, 0, 0, 1, 0),
	nrow = 5, byrow = T)

A <- matrix(c(
	0.3, 0.7,
	0.4, 0.6
), nrow = 2, byrow = T)
c(0.5, 0.5) %*% A %*% A

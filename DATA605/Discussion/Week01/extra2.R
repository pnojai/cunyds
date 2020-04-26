library(pracma)

A_c <- matrix(c(
	2, 1, 7, -7,
	-3, 4, -5, -6,
	1, 1, 4, -5
), nrow = 3, byrow = TRUE)
A_c
rref(A_c)

A_n <- cbind(A_c, 0)
A_n
rref(A_n)

A_a <- cbind(A_c, c(8, -12, 4))
A_a
rref(A_a)

A <- matrix(c(
	1, 2, -1, 1,
	3, 0, 3, -9,
	-1, 4, -5, 11
), nrow = 3, byrow = TRUE)
A
rref(A)

A <- matrix(c(
	-2, -1, -8, 8, 4, -9, -1, -1, -18, 3,
	3, -2, 5, 2, -2, -5, 1, 2, 15, 10,
	4, -2, 8, 0, 2, -14, 0, -2, 2, 36,
	-1, 2, 1, -6, 0, 7, -1, 0, -3, -8,
	3, 2, 13, -14, -1, 5, 0, -1, 12, 15,
	-2, 2, -2, -4, 1, 6, -2, -2, -15, -7 
), nrow = 6, byrow = TRUE)
A
rref(A)

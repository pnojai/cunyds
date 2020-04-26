library('pracma')

# p. 71. Singular or non-singular?
# C30
A <- matrix(c(
	-3, 1, 2, 8,
	2, 0, 3, 4,
	1, 2, 7, -4,
	5, -1, 2, 0
), nrow = 4, byrow = TRUE)
A

RREF <- rref(A)
RREF
identical(RREF, diag(4)) # Careful, rounding.
# Answer: non-singular. Row reduces to identity matrix.

# C31
A <- matrix(c(
	2, 3, 1, 4,
	1, 1, 1, 0,
	-1, 2, 3, 5,
	1, 2, 1, 3
), nrow = 4, byrow = TRUE)
A

RREF <- rref(A)
RREF
identical(RREF, diag(4)) # Careful, rounding.
# Answer: singular. Does not row reduce to identity matrix

# C32
# Answer: Undefined. Matrix isn't square.

# C33
A <- matrix(c(
	-1, 2, 0, 3,
	1, -3, -2, 4,
	-2, 0, 4, 3,
	-3, 1, -2, 3
), nrow = 4, byrow = TRUE)
A

RREF <- rref(A)
RREF
identical(RREF, diag(4)) # Careful, rounding.
# Answer: non-singular. Row reduces to identity matrix.

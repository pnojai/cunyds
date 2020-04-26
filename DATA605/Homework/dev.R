library(pracma)
A <- matrix(c(
	1, 1, 3,
	2, -1, 5,
	-1, -2, 4
), nrow = 3, byrow = TRUE)
rref(A)
# It's the Identity matrix, so I know there is a single solution.

b <- c(1, 2, 6)

A_aug <- cbind(A, b)
A_aug
rref(A_aug)

# RREF <- matrix(data = rep(NA, length(A_aug)), nrow = nrow(A_aug))
A_dev <- A_aug

pivot_col <- 1
eval_row <- 1
multiplier <- A_dev[eval_row + 1, pivot_col] / A_dev[eval_row, pivot_col]
A_dev[eval_row + 1, ] <- A_dev[eval_row + 1, ] - multiplier * A_dev[eval_row, ]

multiplier <- A_dev[eval_row + 2, pivot_col] / A_dev[eval_row, pivot_col]
A_dev[eval_row + 2, ] <- A_dev[eval_row + 2, ] - multiplier * A_dev[eval_row, ]

pivot_col <- 2
eval_row <- 2

multiplier <- A_dev[eval_row + 1, pivot_col] / A_dev[eval_row, pivot_col]
A_dev[eval_row + 1, ] <- A_dev[eval_row + 1, ] - multiplier * A_dev[eval_row, ]

for (i in 1:nrow(A_aug)) {
	
}

A_dev <- A_aug
m <- nrow(A_aug)
n <- ncol(A_aug) - 1
j <- 0
r <- 0

print(A_dev)
gj_dev <- function(A, b) {
	A_aug <- cbind(A, b)
	m <- nrow(A)
	n <- ncol(A)
	j <- 0
	r <- 0
	
	for (j in 1:n) {
		i <- r + 1
		while (i <= m && A_aug[i, j] == 0) {
			i <- i + 1
		}
		if (i < m + 1) {
			r <- r + 1
			A_aug[c(i, r), ] <- A_aug[c(r, i), ]
			A_aug[r, ] <- A_aug[r, ] / A_aug[r, j]
			for (k in 1:m) {
				if (k != r) {
					A_aug[k, ] <- -A_aug[k, j] * A_aug[r, ] + A_aug[k, ]
				}
			}
		}
	}
	return(A_aug[ , (n + 1)])
}

A_dev <- A_aug
print(A_dev)
gj_dev(A, b)

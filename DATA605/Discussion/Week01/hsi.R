# week1_605
# C26 pg. 255
# Author: Justin Hsi

# install.packages('pracma')
library('pracma')

D = cbind(c(-7,6,3,-1), c(-11,10,5,-2), c(-19,18,9,-4), c(-15,14,7,-3))
I = diag(4)
EEF = cbind(D,I)
EEF

RREEF = rref(EEF)
RREEF

# 1. A linearly independent set whose span is the column space of D.
# Colspace of D is Nullspace of L; C(D) is N(L)
L = RREEF[3:4,5:8]
L

null_L = cbind(c(-3,2,1,0), c(-2,0,0,1))
null_L

L%*%null_L

# The columns of null_L are a linearly independent set whose span
# is the columns space of D

# 2. A linearly independent set whose span is the left null space of D.
# Leftnullspace of D is rowspace of L; LN(D) is R(L) Rowspace of L is
# colspace of L-transpose; R(L) is C(L-t)

Lt = t(L)
Lt

# The columns of Lt are a linearly independent set whose span is the
# left null space of D.


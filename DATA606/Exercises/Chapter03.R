
# 3.30
# a
x1 <- c(0, 5, 10, 30)
Px <- c(.5, .25, .23, .02)
x1_Px <- x1 * Px
Ex <- sum(x1_Px)
x1_minus_Ex <- x1 - Ex
x1_minus_Ex_sqr_time_P <- x1_minus_Ex^2 * Px
var_x <- sum(x1_minus_Ex_sqr_time_P)
sd_x <- sqrt(var_x)

# Expected winnings.
Ex
# Standard deviation of winnings.
sd_x

# b
# Don't know.

# 3.31
x1 <- c(0, 25, 50)
Pwin50 <- ((13 / 52) * (12 / 51) * (11 / 50))
Pwin25 <- ((26 / 52) * (25 / 51) * (24 / 50))
Pwin <- Pwin25 + Pwin50
Ploss <- 1 - Pwin
Px <- c(Ploss, Pwin25, Pwin50)

Px
sum(Px)

x1_Px <- x1 * Px
Ex <- sum(x1_Px)
x1_Px
Ex

x1_minus_Ex <- x1 - Ex
x1_minus_Ex
x1_minus_Ex_sqr_time_P <- x1_minus_Ex^2 * Px
x1_minus_Ex_sqr_time_P
var_x <- sum(x1_minus_Ex_sqr_time_P)
var_x
sd_x <- sqrt(var_x)
sd_x

# If game costs $5.
E_profit <- Ex - 5
E_profit

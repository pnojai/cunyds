---
title: "Probability"
output:
  pdf_document:
    keep_md: yes
  html_document:
    css: ./lab.css
    highlight: pygments
    theme: cerulean
---

## Hot Hands

Basketball players who make several baskets in succession are described as 
having a *hot hand*. Fans and players have long believed in the hot hand 
phenomenon, which refutes the assumption that each shot is independent of the 
next. However, a 1985 paper by Gilovich, Vallone, and Tversky collected evidence
that contradicted this belief and showed that successive shots are independent 
events ([http://psych.cornell.edu/sites/default/files/Gilo.Vallone.Tversky.pdf](http://psych.cornell.edu/sites/default/files/Gilo.Vallone.Tversky.pdf)). This paper started a great controversy that continues to this day, as you can 
see by Googling *hot hand basketball*.

We do not expect to resolve this controversy today. However, in this lab we'll 
apply one approach to answering questions like this. The goals for this lab are 
to (1) think about the effects of independent and dependent events, (2) learn 
how to simulate shooting streaks in R, and (3) to compare a simulation to actual
data in order to determine if the hot hand phenomenon appears to be real.

## Saving your code

Click on File -> New -> R Script. This will open a blank document above the 
console. As you go along you can copy and paste your code here and save it. This
is a good way to keep track of your code and be able to reuse it later. To run 
your code from this document you can either copy and paste it into the console, 
highlight the code and hit the Run button, or highlight the code and hit 
command+enter or a mac or control+enter on a PC.

You'll also want to save this script (code document). To do so click on the disk 
icon. The first time you hit save, RStudio will ask for a file name; you can 
name it anything you like. Once you hit save you'll see the file appear under 
the Files tab in the lower right panel. You can reopen this file anytime by 
simply clicking on it.

## Getting Started

Our investigation will focus on the performance of one player: Kobe Bryant of 
the Los Angeles Lakers. His performance against the Orlando Magic in the 2009 
NBA finals earned him the title *Most Valuable Player* and many spectators 
commented on how he appeared to show a hot hand. Let's load some data from those
games and look at the first several rows.


```r
load("more/kobe.RData")
head(kobe)
```

```
##    vs game quarter time
## 1 ORL    1       1 9:47
## 2 ORL    1       1 9:07
## 3 ORL    1       1 8:11
## 4 ORL    1       1 7:41
## 5 ORL    1       1 7:03
## 6 ORL    1       1 6:01
##                                               description basket
## 1                 Kobe Bryant makes 4-foot two point shot      H
## 2                               Kobe Bryant misses jumper      M
## 3                        Kobe Bryant misses 7-foot jumper      M
## 4 Kobe Bryant makes 16-foot jumper (Derek Fisher assists)      H
## 5                         Kobe Bryant makes driving layup      H
## 6                               Kobe Bryant misses jumper      M
```

In this data frame, every row records a shot taken by Kobe Bryant. If he hit the
shot (made a basket), a hit, `H`, is recorded in the column named `basket`, 
otherwise a miss, `M`, is recorded.

Just looking at the string of hits and misses, it can be difficult to gauge 
whether or not it seems like Kobe was shooting with a hot hand. One way we can 
approach this is by considering the belief that hot hand shooters tend to go on 
shooting streaks. For this lab, we define the length of a shooting streak to be 
the *number of consecutive baskets made until a miss occurs*.

For example, in Game 1 Kobe had the following sequence of hits and misses from 
his nine shot attempts in the first quarter:

\[ \textrm{H M | M | H H M | M | M | M} \]

To verify this use the following command:


```r
kobe$basket[1:9]
```

```
## [1] "H" "M" "M" "H" "H" "M" "M" "M" "M"
```

Within the nine shot attempts, there are six streaks, which are separated by a 
"|" above. Their lengths are one, zero, two, zero, zero, zero (in order of 
occurrence).

1.  What does a streak length of 1 mean, i.e. how many hits and misses are in a 
    streak of 1? What about a streak length of 0?

### Answer - BEGIN
A streak length of 1 denotes one hit and one miss, a length of 0, zero hits and one miss.

In general, the streak length equals the number of hits and, by definition, there will always be one miss in the streak, except for the case when the last shot of the game is a hit.

### Answer - END

The custom function `calc_streak`, which was loaded in with the data, may be 
used to calculate the lengths of all shooting streaks and then look at the 
distribution.


```r
kobe_streak <- calc_streak(kobe$basket)
barplot(table(kobe_streak))
```

![](jai-probability_files/figure-latex/calc-streak-kobe-1.pdf)<!-- --> 

Note that instead of making a histogram, we chose to make a bar plot from a 
table of the streak data. A bar plot is preferable here since our variable is 
discrete -- counts -- instead of continuous.

2.  Describe the distribution of Kobe's streak lengths from the 2009 NBA finals. 
    What was his typical streak length? How long was his longest streak of baskets?
    

```r
summary(kobe_streak)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0000  0.0000  0.0000  0.7632  1.0000  4.0000
```
    
### Answer - BEGIN
The distribution of Kobe's streak lengths is unimodal and skewed to the right. His longest streak was 4 hits.

Typical streak length requires some interpretation. The median is 0 and the mean is 0.8. It's a matter of opinion which statistic better represents "typical."

Personally, I challenge the definition of streak in this analysis. I think, in popular usage, "streak" refers to multiple hits in a row. By this definition, there is no such thing as streaks of length 0 or 1. You have to get at least two hits in a row to have a streak.

I wondered what such a definition would do to the summary.


```r
kobe_streak_alt <- kobe_streak[kobe_streak > 1]
summary(kobe_streak_alt)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   2.000   2.000   3.000   2.615   3.000   4.000
```

```r
barplot(table(kobe_streak_alt))
```

![](jai-probability_files/figure-latex/unnamed-chunk-2-1.pdf)<!-- --> 

In this interpretation, the typical streak is more clear. The median length is 3 and the mean is 2.6. This is not a desription of his typical *shot*, but instead his typical *streak*. His typical shot is a miss. Players miss more than they hit, so best if they shoot a lot and win on attempts.

### Answer - END

## Compared to What?

We've shown that Kobe had some long shooting streaks, but are they long enough 
to support the belief that he had hot hands? What can we compare them to?

To answer these questions, let's return to the idea of *independence*. Two 
processes are independent if the outcome of one process doesn't effect the outcome 
of the second. If each shot that a player takes is an independent process, 
having made or missed your first shot will not affect the probability that you
will make or miss your second shot.

A shooter with a hot hand will have shots that are *not* independent of one 
another. Specifically, if the shooter makes his first shot, the hot hand model 
says he will have a *higher* probability of making his second shot.

Let's suppose for a moment that the hot hand model is valid for Kobe. During his
career, the percentage of time Kobe makes a basket (i.e. his shooting 
percentage) is about 45%, or in probability notation,

\[ P(\textrm{shot 1 = H}) = 0.45 \]

If he makes the first shot and has a hot hand (*not* independent shots), then 
the probability that he makes his second shot would go up to, let's say, 60%,

\[ P(\textrm{shot 2 = H} \, | \, \textrm{shot 1 = H}) = 0.60 \]

As a result of these increased probabilites, you'd expect Kobe to have longer 
streaks. Compare this to the skeptical perspective where Kobe does *not* have a
hot hand, where each shot is independent of the next. If he hit his first shot,
the probability that he makes the second is still 0.45.

\[ P(\textrm{shot 2 = H} \, | \, \textrm{shot 1 = H}) = 0.45 \]

In other words, making the first shot did nothing to effect the probability that
he'd make his second shot. If Kobe's shots are independent, then he'd have the 
same probability of hitting every shot regardless of his past shots: 45%.

Now that we've phrased the situation in terms of independent shots, let's return
to the question: how do we tell if Kobe's shooting streaks are long enough to 
indicate that he has hot hands? We can compare his streak lengths to someone
without hot hands: an independent shooter. 

## Simulations in R

While we don't have any data from a shooter we know to have independent shots, 
that sort of data is very easy to simulate in R. In a simulation, you set the 
ground rules of a random process and then the computer uses random numbers to 
generate an outcome that adheres to those rules. As a simple example, you can
simulate flipping a fair coin with the following.


```r
outcomes <- c("heads", "tails")
sample(outcomes, size = 1, replace = TRUE)
```

```
## [1] "tails"
```

The vector `outcomes` can be thought of as a hat with two slips of paper in it: 
one slip says `heads` and the other says `tails`. The function `sample` draws 
one slip from the hat and tells us if it was a head or a tail. 

Run the second command listed above several times. Just like when flipping a 
coin, sometimes you'll get a heads, sometimes you'll get a tails, but in the 
long run, you'd expect to get roughly equal numbers of each.

If you wanted to simulate flipping a fair coin 100 times, you could either run 
the function 100 times or, more simply, adjust the `size` argument, which 
governs how many samples to draw (the `replace = TRUE` argument indicates we put
the slip of paper back in the hat before drawing again). Save the resulting 
vector of heads and tails in a new object called `sim_fair_coin`.


```r
sim_fair_coin <- sample(outcomes, size = 100, replace = TRUE)
```

To view the results of this simulation, type the name of the object and then use
`table` to count up the number of heads and tails.


```r
sim_fair_coin
```

```
##   [1] "tails" "tails" "tails" "tails" "tails" "heads" "tails" "heads"
##   [9] "tails" "tails" "tails" "heads" "heads" "tails" "heads" "tails"
##  [17] "tails" "tails" "tails" "tails" "heads" "tails" "heads" "heads"
##  [25] "heads" "heads" "heads" "tails" "tails" "tails" "heads" "heads"
##  [33] "heads" "heads" "heads" "heads" "heads" "tails" "tails" "heads"
##  [41] "tails" "heads" "tails" "heads" "tails" "heads" "heads" "tails"
##  [49] "heads" "tails" "tails" "tails" "heads" "heads" "tails" "heads"
##  [57] "heads" "heads" "tails" "tails" "tails" "heads" "tails" "tails"
##  [65] "heads" "heads" "heads" "tails" "tails" "heads" "heads" "heads"
##  [73] "heads" "heads" "heads" "tails" "heads" "tails" "tails" "tails"
##  [81] "heads" "heads" "tails" "heads" "heads" "tails" "heads" "heads"
##  [89] "tails" "tails" "heads" "tails" "tails" "tails" "heads" "heads"
##  [97] "heads" "tails" "tails" "tails"
```

```r
table(sim_fair_coin)
```

```
## sim_fair_coin
## heads tails 
##    50    50
```

Since there are only two elements in `outcomes`, the probability that we "flip" 
a coin and it lands heads is 0.5. Say we're trying to simulate an unfair coin 
that we know only lands heads 20% of the time. We can adjust for this by adding 
an argument called `prob`, which provides a vector of two probability weights.


```r
sim_unfair_coin <- sample(outcomes, size = 100, replace = TRUE, prob = c(0.2, 0.8))
```

`prob=c(0.2, 0.8)` indicates that for the two elements in the `outcomes` vector,
we want to select the first one, `heads`, with probability 0.2 and the second 
one, `tails` with probability 0.8. Another way of thinking about this is to 
think of the outcome space as a bag of 10 chips, where 2 chips are labeled 
"head" and 8 chips "tail". Therefore at each draw, the probability of drawing a 
chip that says "head"" is 20%, and "tail" is 80%.

3.  In your simulation of flipping the unfair coin 100 times, how many flips 
    came up heads?

### Answer - BEGIN

```r
set.seed(23) # Setting the seed, so my results are reproducible.
sim_unfair_coin <- sample(outcomes, size = 100, replace = TRUE, prob = c(0.2, 0.8))
unfair_coin_results <- table(sim_unfair_coin)
unfair_coin_results
```

```
## sim_unfair_coin
## heads tails 
##    29    71
```
I got 29 heads.

### Answer - END

In a sense, we've shrunken the size of the slip of paper that says "heads", 
making it less likely to be drawn and we've increased the size of the slip of 
paper saying "tails", making it more likely to be drawn. When we simulated the 
fair coin, both slips of paper were the same size. This happens by default if 
you don't provide a `prob` argument; all elements in the `outcomes` vector have 
an equal probability of being drawn.

If you want to learn more about `sample` or any other function, recall that you 
can always check out its help file.


```r
?sample
```

## Simulating the Independent Shooter

Simulating a basketball player who has independent shots uses the same mechanism 
that we use to simulate a coin flip. To simulate a single shot from an 
independent shooter with a shooting percentage of 50% we type,


```r
outcomes <- c("H", "M")
sim_basket <- sample(outcomes, size = 1, replace = TRUE)
```

To make a valid comparison between Kobe and our simulated independent shooter, 
we need to align both their shooting percentage and the number of attempted shots.

4.  What change needs to be made to the `sample` function so that it reflects a 
    shooting percentage of 45%? Make this adjustment, then run a simulation to 
    sample 133 shots. Assign the output of this simulation to a new object called
    `sim_basket`.

### Answer - BEGIN
We need to adjust the probability of sampling an "H" to 45% and "M" to 55% using the the `prob` parameter.


```r
set.seed(24)
sim_basket <- sample(outcomes, size = 133, replace = TRUE, prob = c(0.45, 0.55))
```

### Answer - END

Note that we've named the new vector `sim_basket`, the same name that we gave to
the previous vector reflecting a shooting percentage of 50%. In this situation, 
R overwrites the old object with the new one, so always make sure that you don't
need the information in an old vector before reassigning its name.

With the results of the simulation saved as `sim_basket`, we have the data 
necessary to compare Kobe to our independent shooter. We can look at Kobe's data 
alongside our simulated data.


```r
kobe$basket
```

```
##   [1] "H" "M" "M" "H" "H" "M" "M" "M" "M" "H" "H" "H" "M" "H" "H" "M" "M"
##  [18] "H" "H" "H" "M" "M" "H" "M" "H" "H" "H" "M" "M" "M" "M" "M" "M" "H"
##  [35] "M" "H" "M" "M" "H" "H" "H" "H" "M" "H" "M" "M" "H" "M" "M" "H" "M"
##  [52] "M" "H" "M" "H" "H" "M" "M" "H" "M" "H" "H" "M" "H" "M" "M" "M" "H"
##  [69] "M" "M" "M" "M" "H" "M" "H" "M" "M" "H" "M" "M" "H" "H" "M" "M" "M"
##  [86] "M" "H" "H" "H" "M" "M" "H" "M" "M" "H" "M" "H" "H" "M" "H" "M" "M"
## [103] "H" "M" "M" "M" "H" "M" "H" "H" "H" "M" "H" "H" "H" "M" "H" "M" "H"
## [120] "M" "M" "M" "M" "M" "M" "H" "M" "H" "M" "M" "M" "M" "H"
```

```r
sim_basket
```

```
##   [1] "M" "M" "H" "M" "H" "H" "M" "H" "H" "M" "H" "M" "H" "H" "M" "H" "M"
##  [18] "M" "M" "M" "M" "H" "H" "M" "M" "H" "M" "H" "H" "M" "M" "M" "M" "M"
##  [35] "H" "M" "H" "H" "H" "H" "M" "M" "M" "M" "M" "M" "M" "M" "M" "M" "M"
##  [52] "H" "M" "H" "M" "H" "M" "M" "M" "M" "M" "M" "M" "M" "H" "M" "H" "H"
##  [69] "H" "M" "M" "M" "M" "H" "H" "M" "H" "H" "M" "H" "M" "M" "M" "M" "M"
##  [86] "M" "M" "H" "M" "H" "M" "H" "H" "M" "M" "H" "H" "M" "M" "M" "H" "H"
## [103] "M" "M" "H" "M" "H" "M" "M" "M" "H" "M" "M" "H" "H" "M" "H" "H" "H"
## [120] "H" "H" "M" "H" "H" "M" "H" "H" "M" "H" "M" "M" "H" "M"
```

Both data sets represent the results of 133 shot attempts, each with the same 
shooting percentage of 45%. We know that our simulated data is from a shooter 
that has independent shots. That is, we know the simulated shooter does not have
a hot hand.

* * *

## On your own

### Comparing Kobe Bryant to the Independent Shooter

Using `calc_streak`, compute the streak lengths of `sim_basket`.

-   Describe the distribution of streak lengths. What is the typical streak 
    length for this simulated independent shooter with a 45% shooting percentage?
    How long is the player's longest streak of baskets in 133 shots?
    
### Answer- BEGIN

```r
sim_streak <- calc_streak(sim_basket)
summary(sim_streak)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  0.0000  0.0000  0.0000  0.6962  1.0000  5.0000
```

```r
barplot(table(sim_streak))
```

![](jai-probability_files/figure-latex/unnamed-chunk-5-1.pdf)<!-- --> 

  - The distibution of streak lengths for the simulation is unimodal and skewed to the right.
  - The median is 0.
  - The simulation's mean is 0.70.
  - The longest streak for the simulation was 5.

### Answer - END

-   If you were to run the simulation of the independent shooter a second time, 
    how would you expect its streak distribution to compare to the distribution 
    from the question above? Exactly the same? Somewhat similar? Totally 
    different? Explain your reasoning.
    
**Answer**

I would expect the streak distribution to be similar, based on continuing independence of each shot event.

-   How does Kobe Bryant's distribution of streak lengths compare to the 
    distribution of streak lengths for the simulated shooter? Using this 
    comparison, do you have evidence that the hot hand model fits Kobe's 
    shooting patterns? Explain.

### Answer - BEGIN
  - Both distributions are unimodal and skewed to the right.
  - The medians are both 0.
  - Kobe's mean was 0.76, higher than the simulation's mean of 0.70.
  - The longest streak for the simulation was 5, compared to Kobe's of 4.

With a higher maximum streak than Kobo, this simulation demonstrated that Kobe's hand was *less* hot than the simulation.

On the other hand (pardon the expression), I confess I don't exactly know how to interpret the difference in means here. If the control is the simulation and its mean streak length was 0.70, and Kobe's test data show a higher mean of 0.76, that's an increase in the mean of 8.6%. I'm hazy on how I'm to interpret this, so I would love guidance about that, please.

### Answer - END

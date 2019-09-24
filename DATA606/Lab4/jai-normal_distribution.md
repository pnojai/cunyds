---
title: "The normal distribution"
author: "Jai Jeffryes"
date: "9/24/2019"
output:
  pdf_document:
    keep_md: yes
  html_document:
    theme: cerulean
    highlight: pygments
    css: ./lab.css
---

In this lab we'll investigate the probability distribution that is most central
to statistics: the normal distribution.  If we are confident that our data are 
nearly normal, that opens the door to many powerful statistical methods.  Here 
we'll use the graphical tools of R to assess the normality of our data and also 
learn how to generate random numbers from a normal distribution.

## The Data

This week we'll be working with measurements of body dimensions.  This data set 
contains measurements from 247 men and 260 women, most of whom were considered 
healthy young adults.


```r
load("more/bdims.RData")
```

Let's take a quick peek at the first few rows of the data.


```r
head(bdims)
```

```
##   bia.di bii.di bit.di che.de che.di elb.di wri.di kne.di ank.di sho.gi
## 1   42.9   26.0   31.5   17.7   28.0   13.1   10.4   18.8   14.1  106.2
## 2   43.7   28.5   33.5   16.9   30.8   14.0   11.8   20.6   15.1  110.5
## 3   40.1   28.2   33.3   20.9   31.7   13.9   10.9   19.7   14.1  115.1
## 4   44.3   29.9   34.0   18.4   28.2   13.9   11.2   20.9   15.0  104.5
## 5   42.5   29.9   34.0   21.5   29.4   15.2   11.6   20.7   14.9  107.5
## 6   43.3   27.0   31.5   19.6   31.3   14.0   11.5   18.8   13.9  119.8
##   che.gi wai.gi nav.gi hip.gi thi.gi bic.gi for.gi kne.gi cal.gi ank.gi
## 1   89.5   71.5   74.5   93.5   51.5   32.5   26.0   34.5   36.5   23.5
## 2   97.0   79.0   86.5   94.8   51.5   34.4   28.0   36.5   37.5   24.5
## 3   97.5   83.2   82.9   95.0   57.3   33.4   28.8   37.0   37.3   21.9
## 4   97.0   77.8   78.8   94.0   53.0   31.0   26.2   37.0   34.8   23.0
## 5   97.5   80.0   82.5   98.5   55.4   32.0   28.4   37.7   38.6   24.4
## 6   99.9   82.5   80.1   95.3   57.5   33.0   28.0   36.6   36.1   23.5
##   wri.gi age  wgt   hgt sex
## 1   16.5  21 65.6 174.0   1
## 2   17.0  23 71.8 175.3   1
## 3   16.9  28 80.7 193.5   1
## 4   16.6  23 72.6 186.5   1
## 5   18.0  22 78.8 187.2   1
## 6   16.9  21 74.8 181.5   1
```

You'll see that for every observation we have 25 measurements, many of which are
either diameters or girths.  A key to the variable names can be found at 
[http://www.openintro.org/stat/data/bdims.php](http://www.openintro.org/stat/data/bdims.php),
but we'll be focusing on just three columns to get started: weight in kg (`wgt`), 
height in cm (`hgt`), and `sex` (`1` indicates male, `0` indicates female).

Since males and females tend to have different body dimensions, it will be 
useful to create two additional data sets: one with only men and another with 
only women.


```r
mdims <- subset(bdims, sex == 1)
fdims <- subset(bdims, sex == 0)
```

1.  Make a histogram of men's heights and a histogram of women's heights.  How 
    would you compare the various aspects of the two distributions?

**ANSWER**

```r
hist(mdims$hgt)
```

![](jai-normal_distribution_files/figure-latex/ans-hist-1.pdf)<!-- --> 

```r
hist(fdims$hgt)
```

![](jai-normal_distribution_files/figure-latex/ans-hist-2.pdf)<!-- --> 

```r
hist(mdims$hgt, breaks = 20)
```

![](jai-normal_distribution_files/figure-latex/ans-hist-3.pdf)<!-- --> 

```r
hist(fdims$hgt, breaks = 20)
```

![](jai-normal_distribution_files/figure-latex/ans-hist-4.pdf)<!-- --> 

- Both appear unimodal.
- Both appear symmetric, but the men's distribution a little more so. There is a little left skew to the women's distribution.
- I plotted both with more bins and it revealed higher variability.

## The normal distribution

In your description of the distributions, did you use words like *bell-shaped* 
or *normal*?  It's tempting to say so when faced with a unimodal symmetric 
distribution.

To see how accurate that description is, we can plot a normal distribution curve 
on top of a histogram to see how closely the data follow a normal distribution. 
This normal curve should have the same mean and standard deviation as the data. 
We'll be working with women's heights, so let's store them as a separate object 
and then calculate some statistics that will be referenced later. 


```r
fhgtmean <- mean(fdims$hgt)
fhgtsd   <- sd(fdims$hgt)
```

Next we make a density histogram to use as the backdrop and use the `lines` 
function to overlay a normal probability curve. The difference between a 
frequency histogram and a density histogram is that while in a frequency 
histogram the *heights* of the bars add up to the total number of observations, 
in a density histogram the *areas* of the bars add up to 1. The area of each bar 
can be calculated as simply the height *times* the width of the bar. Using a 
density histogram allows us to properly overlay a normal distribution curve over 
the histogram since the curve is a normal probability density function.
Frequency and density histograms both display the same exact shape; they only 
differ in their y-axis. You can verify this by comparing the frequency histogram 
you constructed earlier and the density histogram created by the commands below.


```r
hist(fdims$hgt, probability = TRUE, ylim = c(0, 0.06))
x <- 140:190
y <- dnorm(x = x, mean = fhgtmean, sd = fhgtsd)
lines(x = x, y = y, col = "blue")
```

![](jai-normal_distribution_files/figure-latex/hist-height-1.pdf)<!-- --> 

After plotting the density histogram with the first command, we create the x- 
and y-coordinates for the normal curve.  We chose the `x` range as 140 to 190 in 
order to span the entire range of `fheight`.  To create `y`, we use `dnorm` to 
calculate the density of each of those x-values in a distribution that is normal
with mean `fhgtmean` and standard deviation `fhgtsd`.  The final command draws a
curve on the existing plot (the density histogram) by connecting each of the 
points specified by `x` and `y`. The argument `col` simply sets the color for 
the line to be drawn. If we left it out, the line would be drawn in black.

The top of the curve is cut off because the limits of the x- and y-axes are set 
to best fit the histogram.  To adjust the y-axis you can add a third argument to
the histogram function: `ylim = c(0, 0.06)`.

2.  Based on the this plot, does it appear that the data follow a nearly normal 
    distribution?

**ANSWER**
Yes, seems like it to me.

## Evaluating the normal distribution

Eyeballing the shape of the histogram is one way to determine if the data appear
to be nearly normally distributed, but it can be frustrating to decide just how 
close the histogram is to the curve. An alternative approach involves 
constructing a normal probability plot, also called a normal Q-Q plot for 
"quantile-quantile".


```r
qqnorm(fdims$hgt)
qqline(fdims$hgt)
```

![](jai-normal_distribution_files/figure-latex/qq-1.pdf)<!-- --> 

A data set that is nearly normal will result in a probability plot where the 
points closely follow the line.  Any deviations from normality leads to 
deviations of these points from the line.  The plot for female heights shows 
points that tend to follow the line but with some errant points towards the 
tails.  We're left with the same problem that we encountered with the histogram 
above: how close is close enough?

A useful way to address this question is to rephrase it as: what do probability 
plots look like for data that I *know* came from a normal distribution?  We can 
answer this by simulating data from a normal distribution using `rnorm`.


```r
sim_norm <- rnorm(n = length(fdims$hgt), mean = fhgtmean, sd = fhgtsd)
```

The first argument indicates how many numbers you'd like to generate, which we 
specify to be the same number of heights in the `fdims` data set using the 
`length` function.  The last two arguments determine the mean and standard 
deviation of the normal distribution from which the simulated sample will be 
generated.  We can take a look at the shape of our simulated data set, `sim_norm`, 
as well as its normal probability plot.

3.  Make a normal probability plot of `sim_norm`.  Do all of the points fall on 
    the line?  How does this plot compare to the probability plot for the real 
    data?

**ANSWER**

Not all of the points fall on the line. They begin to diverge beyond 1 Standard Deviation. However, this region of congruence is wider than the real data, whose congruent region runs right about up to 1 Standard Deviation.


```r
qqnorm(sim_norm)
qqline(sim_norm)
```

![](jai-normal_distribution_files/figure-latex/ans-sim_norm-1.pdf)<!-- --> 

Even better than comparing the original plot to a single plot generated from a 
normal distribution is to compare it to many more plots using the following 
function. It may be helpful to click the zoom button in the plot window.


```r
qqnormsim(fdims$hgt)
```

![](jai-normal_distribution_files/figure-latex/qqnormsim-1.pdf)<!-- --> 

4.  Does the normal probability plot for `fdims$hgt` look similar to the plots 
    created for the simulated data?  That is, do plots provide evidence that the
    female heights are nearly normal?
    
**ANSWER**

Yes, although there is some departure even within the region of 1 standard deviation.

5.  Using the same technique, determine whether or not female weights appear to 
    come from a normal distribution.
    
**ANSWER**

My first QQ plot did not fit a normal distribution very well (many points fell off the line), but when I sampled multiple times with `qnormsim()`, the normal distribution was more apparent.


```r
qqnorm(fdims$wgt)
qqline(fdims$wgt)
```

![](jai-normal_distribution_files/figure-latex/ans-qq-1.pdf)<!-- --> 

```r
qqnormsim(fdims$wgt)
```

![](jai-normal_distribution_files/figure-latex/ans-qq-2.pdf)<!-- --> 

## Normal probabilities

Okay, so now you have a slew of tools to judge whether or not a variable is 
normally distributed.  Why should we care?

It turns out that statisticians know a lot about the normal distribution.  Once 
we decide that a random variable is approximately normal, we can answer all 
sorts of questions about that variable related to probability.  Take, for 
example, the question of, "What is the probability that a randomly chosen young 
adult female is taller than 6 feet (about 182 cm)?" (The study that published
this data set is clear to point out that the sample was not random and therefore 
inference to a general population is not suggested.  We do so here only as an
exercise.)

If we assume that female heights are normally distributed (a very close 
approximation is also okay), we can find this probability by calculating a Z 
score and consulting a Z table (also called a normal probability table).  In R, 
this is done in one step with the function `pnorm`.


```r
1 - pnorm(q = 182, mean = fhgtmean, sd = fhgtsd)
```

```
## [1] 0.004434387
```

Note that the function `pnorm` gives the area under the normal curve below a 
given value, `q`, with a given mean and standard deviation.  Since we're 
interested in the probability that someone is taller than 182 cm, we have to 
take one minus that probability.

Assuming a normal distribution has allowed us to calculate a theoretical 
probability.  If we want to calculate the probability empirically, we simply 
need to determine how many observations fall above 182 then divide this number 
by the total sample size.


```r
sum(fdims$hgt > 182) / length(fdims$hgt)
```

```
## [1] 0.003846154
```

Although the probabilities are not exactly the same, they are reasonably close. 
The closer that your distribution is to being normal, the more accurate the 
theoretical probabilities will be.

6.  Write out two probability questions that you would like to answer; one 
    regarding female heights and one regarding female weights.  Calculate the 
    those probabilities using both the theoretical normal distribution as well 
    as the empirical distribution (four probabilities in all).  Which variable,
    height or weight, had a closer agreement between the two methods?
    
**ANSWER**


```r
fwgtmean <- mean(fdims$wgt)
fwgtsd <- sd(fdims$wgt)

f_taller_theor <- (1 - pnorm(q = 171.4, mean = fhgtmean, sd = fhgtsd)) * 100
f_taller_emp <- (sum(fdims$hgt > 171.4) / length(fdims$hgt)) * 100

f_heavier_theor <- (1 - pnorm(q = 59.6, mean = fwgtmean, sd = fwgtsd)) * 100
f_heavier_emp <- (sum(fdims$wgt > 59.6) / length(fdims$wgt)) * 100

f_taller_diff <- ((f_taller_theor - f_taller_emp) / f_taller_emp) * 100
f_heavier_diff <- ((f_heavier_theor - f_heavier_emp) / f_heavier_emp) * 100
```

- What percentage of women are taller than I (171.4 cm)?
  - Theoretical: 15.9281261%.
  - Empirical: 16.5384615%.
  - The theoretical method differed from the empirical by -3.6904002%.
- What percentage of women are heavier than I (59.6 kg)?
  - Theoretical: 54.1429849%.
  - Empirical: 47.3076923%.
  - The theoretical method differed from the empirical by 14.448586%.
- The height variable agrees more between the theoretical and empirical methods of probability calculation.


* * *

## On Your Own

-   Now let's consider some of the other variables in the body dimensions data 
    set.  Using the figures at the end of the exercises, match the histogram to 
    its normal probability plot.  All of the variables have been standardized 
    (first subtract the mean, then divide by the standard deviation), so the 
    units won't be of any help.  If you are uncertain based on these figures, 
    generate the plots in R to check.
    



    **a.** The histogram for female biiliac (pelvic) diameter (`bii.di`) belongs
    to normal probability plot letter **B**.

    **b.** The histogram for female elbow diameter (`elb.di`) belongs to normal 
    probability plot letter **C**.

    **c.** The histogram for general age (`age`) belongs to normal probability 
    plot letter **D**.

    **d.** The histogram for female chest depth (`che.de`) belongs to normal 
    probability plot letter **A**.

-   Note that normal probability plots C and D have a slight stepwise pattern.  
    Why do you think this is the case?
    
    **ANSWER**
    
    I suspect it is due to rounding of the experimental data.

-   As you can see, normal probability plots can be used both to assess 
    normality and visualize skewness.  Make a normal probability plot for female 
    knee diameter (`kne.di`).  Based on this normal probability plot, is this 
    variable left skewed, symmetric, or right skewed?  Use a histogram to confirm 
    your findings.


```r
qqnorm(fdims$kne.di)
qqline(fdims$kne.di)
```

![](jai-normal_distribution_files/figure-latex/ans-knee-1.pdf)<!-- --> 

**ANSWER**

Right-skewed. 


```r
hist(fdims$kne.di)
```

![](jai-normal_distribution_files/figure-latex/ans-skewchk-1.pdf)<!-- --> 
![histQQmatch](more/histQQmatch.png)


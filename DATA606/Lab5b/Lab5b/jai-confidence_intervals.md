---
title: 'Foundations for statistical inference - Confidence intervals'
author: "Jai Jeffryes"
date: "10/12/2019"
output:
  pdf_document:
    keep_md: yes
  html_document:
    css: ./lab.css
    highlight: pygments
    theme: cerulean
---

## Sampling from Ames, Iowa

If you have access to data on an entire population, say the size of every 
house in Ames, Iowa, it's straight forward to answer questions like, "How big 
is the typical house in Ames?" and "How much variation is there in sizes of 
houses?". If you have access to only a sample of the population, as is often 
the case, the task becomes more complicated. What is your best guess for the 
typical size if you only know the sizes of several dozen houses? This sort of 
situation requires that you use your sample to make inference on what your 
population looks like.

## The data

In the previous lab, ``Sampling Distributions'', we looked at the population data
of houses from Ames, Iowa. Let's start by loading that data set.


```r
load("more/ames.RData")
```

In this lab we'll start with a simple random sample of size 60 from the 
population. Specifically, this is a simple random sample of size 60. Note that 
the data set has information on many housing variables, but for the first 
portion of the lab we'll focus on the size of the house, represented by the 
variable `Gr.Liv.Area`.


```r
population <- ames$Gr.Liv.Area
samp <- sample(population, 60)
samp_mean <- mean(samp)
hist(samp)
```

![](jai-confidence_intervals_files/figure-latex/sample-1.pdf)<!-- --> 

1.  Describe the distribution of your sample. What would you say is the 
"typical" size within your sample? Also state precisely what you interpreted 
"typical" to mean.

The typical size is 1493 square feet. I interpret typical to mean the statistical mean.

2.  Would you expect another student's distribution to be identical to yours? 
Would you expect it to be similar? Why or why not?

Not identical, but close, due to the Central Limit Theorem.

## Confidence intervals

One of the most common ways to describe the typical or central value of a 
distribution is to use the mean. In this case we can calculate the mean of the 
sample using,


```r
sample_mean <- mean(samp)
```

Return for a moment to the question that first motivated this lab: based on 
this sample, what can we infer about the population? Based only on this single 
sample, the best estimate of the average living area of houses sold in Ames 
would be the sample mean, usually denoted as $\bar{x}$ (here we're calling it 
`sample_mean`). That serves as a good *point estimate* but it would be useful 
to also communicate how uncertain we are of that estimate. This can be 
captured by using a *confidence interval*.

We can calculate a 95% confidence interval for a sample mean by adding and 
subtracting 1.96 standard errors to the point estimate (See Section 4.2.3 if 
you are unfamiliar with this formula).


```r
se <- sd(samp) / sqrt(60)
lower <- sample_mean - 1.96 * se
upper <- sample_mean + 1.96 * se
c(lower, upper)
```

```
## [1] 1337.665 1648.602
```

**QUESTION**

I'm getting a little confused about computation of Sample Error. The reference to Section 4.2.3 appears to be incorrect. What I do find in the book is a formula for computation of Sample Error that says `sqrt((p * (1 - p)) / n)`. That's different from `sd(samp / sqrt(60)`. Is that because the first one is Sample Error for a proportion and the second one is Sample Error for... whatever that is?

This is an important inference that we've just made: even though we don't know 
what the full population looks like, we're 95% confident that the true 
average size of houses in Ames lies between the values *lower* and *upper*. 
There are a few conditions that must be met for this interval to be valid.

3.  For the confidence interval to be valid, the sample mean must be normally 
distributed and have standard error $s / \sqrt{n}$. What conditions must be 
met for this to be true?

**ANSWER**

- The observations must be independant, that is, simple random samples.
- The product of the sample size, n, and the population proportion (or plugging in the sample proportion) must be greater than 10.
- The product of the sample size, n, and the complement of the population proportion (or sample proportion) must be greater than 10.

## Confidence levels

4.  What does "95% confidence" mean? If you're not sure, see Section 4.2.2.

**ANSWER**

It is the probability that the population mean lies within the confidence interval.

In this case we have the luxury of knowing the true population mean since we 
have data on the entire population. This value can be calculated using the 
following command:


```r
mean(population)
```

```
## [1] 1499.69
```

5.  Does your confidence interval capture the true average size of houses in 
Ames? If you are working on this lab in a classroom, does your neighbor's 
interval capture this value? 

**ANSWER**

```r
in_ci <- lower <= mean(population) & mean(population) <= upper
```

- Confidence interval: 1337.6646325, 1648.6020342
- Population mean: 1499.6904437
- Confidence interval captures true averge: TRUE

6.  Each student in your class should have gotten a slightly different 
confidence interval. What proportion of those intervals would you expect to 
capture the true population mean? Why? If you are working in this lab in a 
classroom, collect data on the intervals created by other students in the 
class and calculate the proportion of intervals that capture the true 
population mean.

**ANSWER**

95% of such a class would be expected to capture the true population mean because the confidence interval was constructed from a Z-score of 1.96, which demarks 95% of the range of a normal distribution.

Using R, we're going to recreate many samples to learn more about how sample 
means and confidence intervals vary from one sample to another. *Loops* come 
in handy here (If you are unfamiliar with loops, review the [Sampling Distribution Lab](http://htmlpreview.github.io/?https://github.com/andrewpbray/oiLabs/blob/master/sampling_distributions/sampling_distributions.html)).

Here is the rough outline:

-   Obtain a random sample.
-   Calculate and store the sample's mean and standard deviation.
-   Repeat steps (1) and (2) 50 times.
-   Use these stored statistics to calculate many confidence intervals.

But before we do all of this, we need to first create empty vectors where we 
can save the means and standard deviations that will be calculated from each 
sample. And while we're at it, let's also store the desired sample size as `n`.


```r
samp_mean <- rep(NA, 50)
samp_sd <- rep(NA, 50)
n <- 60
```

Now we're ready for the loop where we calculate the means and standard deviations of 50 random samples.


```r
for(i in 1:50){
  samp <- sample(population, n) # obtain a sample of size n = 60 from the population
  samp_mean[i] <- mean(samp)    # save sample mean in ith element of samp_mean
  samp_sd[i] <- sd(samp)        # save sample sd in ith element of samp_sd
}
```

Lastly, we construct the confidence intervals.


```r
lower_vector <- samp_mean - 1.96 * samp_sd / sqrt(n) 
upper_vector <- samp_mean + 1.96 * samp_sd / sqrt(n)
```

Lower bounds of these 50 confidence intervals are stored in `lower_vector`, 
and the upper bounds are in `upper_vector`. Let's view the first interval.


```r
c(lower_vector[1], upper_vector[1])
```

```
## [1] 1303.878 1511.755
```

* * *

## On your own

-   Using the following function (which was downloaded with the data set), 
    plot all intervals. What proportion of your confidence intervals include 
    the true population mean? Is this proportion exactly equal to the 
    confidence level? If not, explain why.

**ANSWER**

One interactive execution produced 2 intervals that excluded the population mean. 48 of 50 included it. That's a proportion of 0.96, which differs from the confidence level by 0.01. With only 50 samples, a proportion of exactly 0.95 is impossible. 47 out of 50 would have been a proportion of 0.94. Even with more samples, the proportion is not guaranteed to be identical to the confidence level, only likely.


```r
plot_ci(lower_vector, upper_vector, mean(population))
```

![](jai-confidence_intervals_files/figure-latex/plot-ci-1.pdf)<!-- --> 

-   Pick a confidence level of your choosing, provided it is not 95%. What is 
    the appropriate critical value?

**ANSWER**

Do you mean the Z-score for the desired confidence interval, the factor by which to multiply the standard error? If I want a confidence interval of 99%, I need a factor of 2.58. The confidence interval is the point estimate plus or minus 2.58 * *SE*.

-   Calculate 50 confidence intervals at the confidence level you chose in the 
    previous question. You do not need to obtain new samples, simply calculate 
    new intervals based on the sample means and standard deviations you have 
    already collected. Using the `plot_ci` function, plot all intervals and 
    calculate the proportion of intervals that include the true population 
    mean. How does this percentage compare to the confidence level selected for
    the intervals?
    
**ANSWER**

I chose a confidence level of 99%. When I calculated confidence intervals interactively, 100% of the intervals contained the population mean, even better than the confidence level.


```r
lower_vector <- samp_mean - 2.58 * samp_sd / sqrt(n) 
upper_vector <- samp_mean + 2.58 * samp_sd / sqrt(n)
plot_ci(lower_vector, upper_vector, mean(population))
```

![](jai-confidence_intervals_files/figure-latex/ci99-1.pdf)<!-- --> 

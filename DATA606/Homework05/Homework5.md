---
title: "Chapter 5 - Foundations for Inference"
author: "Jai Jeffryes"
date: "10/13/2910"
output:
    pdf_document:
        keep_md: true
        extra_dependencies: ["geometry", "multicol", "multirow"]
---



**Heights of adults.** (7.7, p. 260) Researchers studying anthropometry collected body girth measurements and skeletal diameter measurements, as well as age, weight, height and gender, for 507 physically active individuals. The histogram below shows the sample distribution of heights in centimeters.

![](Homework5_files/figure-latex/unnamed-chunk-1-1.pdf)<!-- --> 

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   147.2   163.8   170.3   171.1   177.8   198.1
```

(a) What is the point estimate for the average height of active individuals? What about the median?

- **Mean: 171 cm.**
- **Median: 170 cm.**

(b) What is the point estimate for the standard deviation of the heights of active individuals? What about the IQR?

- **SD: 9.41**
- **IQR: 14**

(c) Is a person who is 1m 80cm (180 cm) tall considered unusually tall? And is a person who is 1m 55cm (155cm) considered unusually short? Explain your reasoning.

- **180 cm. is unusually tall. A person of that height falls in the fourth quartile. Furthermore, their Z-score is 1.9, which puts them in a percentile of 0.97, the proportion of the sample whose height is less than theirs.**
- **155 cm. is unusually short. Such a person lies in the first quartile, their Z-score is -1.72 with a percentile of 0.04. They are shorter than a proportion of 0.96 of the sample.**

(d) The researchers take another random sample of physically active individuals. Would you expect the mean and the standard deviation of this new sample to be the ones given above? Explain your reasoning.

**No, I would expect successive samples to form new sample distributions. Larger sample sizes will have statistics that converge on the population statistics.**

(e) The sample means obtained are point estimates for the mean height of all active individuals, if the sample of individuals is equivalent to a simple random sample. What measure do we use to quantify the variability of such an estimate (Hint: recall that $SD_x = \frac{\sigma}{\sqrt{n}}$)? Compute this quantity using the data from the original sample under the condition that the data are a simple random sample.

**Standard error: 0.4177887**

--------------------------------------------------------------------------------

\clearpage

**Thanksgiving spending, Part I.** The 2009 holiday retail season, which kicked off on November 27, 2009 (the day after Thanksgiving), had been marked by somewhat lower self-reported consumer spending than was seen during the comparable period in 2008. To get an estimate of consumer spending, 436 randomly sampled American adults were surveyed. Daily consumer spending for the six-day period after Thanksgiving, spanning the Black Friday weekend and Cyber Monday, averaged $84.71. A 95% confidence interval based on this sample is ($80.31, $89.11). Determine whether the following statements are true or false, and explain your reasoning.

![](Homework5_files/figure-latex/unnamed-chunk-2-1.pdf)<!-- --> 

(a) We are 95% confident that the average spending of these 436 American adults is between $80.31 and $89.11.

**False. Confidence intervals speak of the population, not the sample. We know the average spending of the sample of 436 with certainty. We are 95% confident that the average spending of the population of American adults lies within the interval of $80.31 to $89.11.**

(b) This confidence interval is not valid since the distribution of spending in the sample is right skewed.

**True. The Central Limit Theorem requires a normal distribution. (Question: I'm a little confused about the context of this question. I see discussion of this topic in chapter 6, but we're only on chapter 5.)**

(c) 95% of random samples have a sample mean between $80.31 and $89.11.

**False. The statement is vague in its use of the word, "samples." 463 samples were taken one time. Those 463 samples have a mean. The confidence interval for that sample mean is 95% likely to contain the population mean.**

(d) We are 95% confident that the average spending of all American adults is between $80.31 and $89.11.

**True.**

(e) A 90% confidence interval would be narrower than the 95% confidence interval since we don’t need to be as sure about our estimate.

**True. A lower standard deviation would encompass 90% of the sample distribution. There would be less chance that the confidence interval contains the population mean.**

(f) In order to decrease the margin of error of a 95% confidence interval to a third of what it is now, we would need to use a sample 3 times larger.

**False. We would need a sample 9 times larger, as the formula for sample error has the square root of the sample size in the denominator.**

(g) The margin of error is 4.4.

**True. The margin of error is half of the confidence interval.**






--------------------------------------------------------------------------------

\clearpage

**Gifted children, Part I.** Researchers investigating characteristics of gifted children col- lected data from schools in a large city on a random sample of thirty-six children who were identified as gifted children soon after they reached the age of four. The following histogram shows the dis- tribution of the ages (in months) at which these children first counted to 10 successfully. Also provided are some sample statistics.

**UNANSWERED**

I am unprepared for questions related to Chapter 7. I thought we were still on Chapter 5. I need to submit this homework incomplete. I haven't supplied any answers beyond this point.

![](Homework5_files/figure-latex/unnamed-chunk-3-1.pdf)<!-- --> 

\begin{tabular}{r | l}
n   & 36 \\
min & 21 \\
mean    & 30.69 \\
sd  & 4.31 \\
max & 39 
\end{tabular}

(a) Are conditions for inference satisfied?
(b) Suppose you read online that children first count to 10 successfully when they are 32 months old, on average. Perform a hypothesis test to evaluate if these data provide convincing evidence that the average age at which gifted children first count to 10 successfully is less than the general average of 32 months. Use a significance level of 0.10.
(c) Interpret the p-value in context of the hypothesis test and the data.
(d) Calculate a 90% confidence interval for the average age at which gifted children first count to 10 successfully.
(e) Do your results from the hypothesis test and the confidence interval agree? Explain.





--------------------------------------------------------------------------------

\clearpage

**Gifted children, Part II.** Exercise above describes a study on gifted children. In this study, along with variables on the children, the researchers also collected data on the mother’s and father’s IQ of the 36 randomly sampled gifted children. The histogram below shows the distribution of mother’s IQ. Also provided are some sample statistics.

![](Homework5_files/figure-latex/unnamed-chunk-4-1.pdf)<!-- --> 

\begin{tabular}{r | l}
n   & 36 \\
min & 101 \\
mean    & 118.2 \\
sd  & 6.5 \\
max & 131 
\end{tabular}

(a) Performahypothesistesttoevaluateifthesedataprovideconvincingevidencethattheaverage IQ of mothers of gifted children is different than the average IQ for the population at large, which is 100. Use a significance level of 0.10.
(b) Calculate a 90% confidence interval for the average IQ of mothers of gifted children.
(c) Do your results from the hypothesis test and the confidence interval agree? Explain.





--------------------------------------------------------------------------------

\clearpage

**CLT.** Define the term “sampling distribution” of the mean, and describe how the shape, center, and spread of the sampling distribution of the mean change as sample size increases.





--------------------------------------------------------------------------------

\clearpage

**CFLBs.** A manufacturer of compact fluorescent light bulbs advertises that the distribution of the lifespans of these light bulbs is nearly normal with a mean of 9,000 hours and a standard deviation of 1,000 hours.

(a) What is the probability that a randomly chosen light bulb lasts more than 10,500 hours?
(b) Describe the distribution of the mean lifespan of 15 light bulbs.
(c) What is the probability that the mean lifespan of 15 randomly chosen light bulbs is more than 10,500 hours?
(d) Sketch the two distributions (population and sampling) on the same scale.
(e) Could you estimate the probabilities from parts (a) and (c) if the lifespans of light bulbs had a skewed distribution?






--------------------------------------------------------------------------------

\clearpage

**Same observation, different sample size.** Suppose you conduct a hypothesis test based on a sample where the sample size is n = 50, and arrive at a p-value of 0.08. You then refer back to your notes and discover that you made a careless mistake, the sample size should have been n = 500. Will your p-value increase, decrease, or stay the same? Explain.






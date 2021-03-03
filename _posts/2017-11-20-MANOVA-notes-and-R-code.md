---
layout: post
title: "Multivariate ANOVA (MANOVA) -- Notes and R Code"
author: "Gaoping Huang"
tags: R
use_math: true
use_bootstrap: false
---



This post covers my notes of **multivariate ANOVA** (MANOVA) methods using R from the book "Discovering Statistics using R (2012)" by Andy Field. Most code and text are directly copied from the book. All the credit goes to him.

## Contents
{:.no_toc}
* Will be replaced with the ToC, excluding the "Contents" header above
{:toc}


## 0. Why MANOVA?

In previous posts, we have seen how to detect group differences on a single dependent variable. However, there may be circumstances in which we are interested in several dependent variables, and in these cases the simple ANOVA model is inadequate.

Why don't we conduct multiple ANOVA for each dependent variable? The reason is that: the more tests we conduct on the same data, the more we inflate the family-wise error rate (the greater chance of making a Type I error).

Moreover, MANOVA, by including all dependent variables in the same analysis, can capture the relationship between outcome variables. Related to this point, ANOVA can tell us only whether groups differ along a single dimension, whereas MANOVA has the power to detect whether groups differ along a combination of dimensions.

**Words of warning**: do not include **lots of dependent variables** in a MANOVA just because you have measured them.


## 1. OCD example used in this chapter

This chapter will use this simple example: the effects of cognitive behavior therapy (CBT) on obsessive compulsive disorder (OCD). Two dependent variables (DV1 and DV2) are considered: the occurrence of obsession-related behaviors (**Actions**) and the occurrence of obsession-related cognitions (**Thoughts**). OCD sufferers are grouped into three conditions: with CBT, with behavior therapy (BT), and with no-treatment (NT).

The raw data is stored at: [assets/Rdata/OCD.dat](/assets/Rdata/OCD.dat).

## 2. Theory of MANOVA

In ANOVA, the variances (systematic and unsystematic) are single values. In MANOVA, these variances are contained in a matrix.

- **hypothesis SSCP:** the matrix that represents the systematic variance and is called *hypothesis sum of squares and cross-products matrix*, denoted by `H`.
- **error SSCP:** the matrix that represents the unsystematic variance and is called *error sum of squares and cross-products matrix*, denoted by `E`.
- **total SSCP:** total amount of variance, denoted by `T`.

Cross-products represent a total value for the combined error between two variables (so in some sense they represent an unstandardized estimate of the total correlation between two variables).

In the Section 16.4.3, the author calculates MANOVA by hand for the OCD example mentioned above. The steps include:
1. Univariate ANOVA for DV1 (**Actions**)
2. Univariate ANOVA for DV2 (**Thoughts**)
3. The relationship between DVs: cross-products
4. The total SSCP matrix (T)
5. The residual (error) SSCP matrix (E)
6. The model (hypothesis) SSCP matrix (H)

Similar to ANOVA, we need to get the ratio of the systematic variance to the unsystematic variance. In terms of matrix, we multiply H by the inverse of E (denoted as $E^{-1}$). We thus have $HE^{−1}$, which is conceptually the same as the F-ratio in univariate ANOVA.

### Pillai-Bartlett Trace (also known as Pillai's trace)
Pillai's trace is used as a test statistic in MANOVA. It is a positive valued statistic ranging from 0 to 1. Increasing values means that effects are contributing more to the model; you should reject the null hypothesis for large values.

Pillai's trace is considered to be the most powerful and robust statistic for general use, especially for departures from assumptions. Other commonly used tests include: Hotelling's $T^2$, Roy's largest root and Wilks's lambda.


## 3. MANOVA Using R

### 3.0 Packages
You will need the packages `car` (for looking at Type III sums of squares), `ggplot2` (for graphs), `MASS` (for discriminant function analysis), `mvoutlier` (for plots to look for multivariate outliers), `mvnormtest` (to test for multivariate normality), `pastecs` (for descriptive statistics), `reshape` (for reshaping the data) and `WRS` (for robust tests). The MASS package is automatically installed, and just use `install.packages("package_name")` to install any package(s) that you don't already have. There is one exception `WRS`, which is a collection of R functions written by Rand Wilcox. In the book, the command to install it is as below, but seems outdated:
```R
install.packages("WRS", repos="http://R-Forge.R-project.org")
```
To install it properly, you can get it from [Wilcox's website](https://dornsife.usc.edu/labs/rwilcox/software/), which shows several options: 1) download it to disk and run R command `source(file.choose())`, 2) go to a GitHub website. I found a third way that runs the following code:
```R
# Directly source the latest version Rallfun-v38.txt
source("https://dornsife.usc.edu/assets/sites/239/docs/Rallfun-v38.txt")
```
Since all functions become available in R environment, there is no need to call `library(WRS)`. 

Then run `library(package_name)` for other packages. Note that the code below may not use all of the packages above, because it is just a brief note of the more detailed book chapter. At least include `mvnormtest`.

### 3.1 Enter data
The data is stored at: [assets/Rdata/OCD.dat](/assets/Rdata/OCD.dat).

{% highlight r %}
ocdData <- read.delim("../assets/Rdata/OCD.dat", header = TRUE)
# rename level label
ocdData$Group<-factor(ocdData$Group, levels = c("CBT", "BT", "No Treatment Control"), labels = c("CBT", "BT", "NT"))
str(ocdData)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	30 obs. of  3 variables:
##  $ Group   : Factor w/ 3 levels "CBT","BT","NT": 1 1 1 1 1 1 1 1 1 1 ...
##  $ Actions : int  5 5 4 4 5 3 7 6 6 4 ...
##  $ Thoughts: int  14 11 16 13 12 14 12 15 16 11 ...
{% endhighlight %}

### 3.2 Explore the data
Use *ggplot2* to plot boxplots of treatment group on the x-axis and obsession-related thoughts and actions displayed on the y-axis (in different colors).


{% highlight r %}
library(reshape2)  # for melt() function
library(ggplot2)
# First we need to restructure the data into long format:
ocdMelt <- melt(ocdData, id=c('Group'), measured=c('Actions', 'Thoughts'))
names(ocdMelt) <- c('Group', 'Outcome_Measure', 'Frequency')
# plot
ocdBoxplot <- ggplot(ocdMelt, aes(Group, Frequency, color = Outcome_Measure))
ocdBoxplot + geom_boxplot() + labs(x='Treatment Group', y='Number of Thoughts/Actions', color='Outcome_Measure') + scale_y_continuous(breaks=seq(0,20, by=2))
{% endhighlight %}

![plot of chunk self_test](/assets/Rfig/multivariate-ANOVA-notes-self_test-1.svg)

The only noteworthy point really is that there is some evidence of an outlier in the no-treatment group (for Thoughts) and, in the same group, scores for Actions seem like they might be a little skewed (there is no lower tail).

Also, we can use `by()` and `stat.desc()` in the `pastecs` package to get descriptive statistics for separate groups. (Skipped here.)

Moreover, we can test the assumption of multivariate normality by using `mshapiro.test()` in `mvnormtest` package. (Skipped here.)


### 3.3 Do the MANOVA
We use the `manova()` function, which takes exactly the same form as `aov()`.
As with most of the models in this book, we have one outcome variable. However, in MANOVA, we have several outcomes, so we need to bind them into one variable.

{% highlight r %}
outcome <- cbind(ocdData$Actions, ocdData$Thoughts)
{% endhighlight %}
Then we use this new variable as the outcome (containing Actions and Thoughts) in our model:

{% highlight r %}
ocdModel <- manova(outcome ~ Group, data=ocdData)
{% endhighlight %}
To see the output of the model, we use the summary command; by default, Pillai's trace is used, but we can set other tests as well.

{% highlight r %}
summary(ocdModel, intercept=TRUE)
{% endhighlight %}



{% highlight text %}
##             Df  Pillai approx F num Df den Df  Pr(>F)    
## (Intercept)  1 0.98285   745.23      2     26 < 2e-16 ***
## Group        2 0.31845     2.56      4     54 0.04904 *  
## Residuals   27                                           
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}



{% highlight r %}
# Or use other tests
# summary(ocdModel, intercept=TRUE, test="Wilks")
# summary(ocdModel, intercept=TRUE, test="Hotelling")
# summary(ocdModel, intercept=TRUE, test="Roy")
{% endhighlight %}
For the Group variable, Pillai's trace has p value 0.049, which indicates a significant difference.

However, we are still unclear about: which groups differed from which; and whether the effect of therapy was on the Thoughts, Actions, or a combination of both.

To determine that, we can look at univariate tests.

### 3.4 Follow-up analysis: univariate test statistics
We can simply execute:

{% highlight r %}
summary.aov(ocdModel)
{% endhighlight %}



{% highlight text %}
##  Response 1 :
##             Df Sum Sq Mean Sq F value  Pr(>F)  
## Group        2 10.467  5.2333  2.7706 0.08046 .
## Residuals   27 51.000  1.8889                  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##  Response 2 :
##             Df  Sum Sq Mean Sq F value Pr(>F)
## Group        2  19.467  9.7333  2.1541 0.1355
## Residuals   27 122.000  4.5185
{% endhighlight %}
The table labelled *Response 1* is for the Actions variable and *Response 2* is for the Thoughts variable.

Note that the F values and p values from this follow-up analysis of MANOVA are *identical* to those obtained if one-way ANOVA was conducted on each dependent variable.

The p values indicate that there was no significant difference between therapy groups in terms of Thoughts (p=.136) and Actions (p=.08). However, we already know that therapy had a significant impact on OCD based on MANOVA. The reason for the anomaly is simple: **the MANOVA takes account of the correlation between dependent variables, and so for these data it has more power to detect group differences.**

### 3.5 Contrasts
Note that because the univariate ANOVAs above were both non-significant, we should not interpret these contrasts. However, we still do it purely for an example.

#### Set contrasts
It makes sense to compare each of the treatment groups to the no-treatment control group. We can set the contrasts manually with some meaningful names:

{% highlight r %}
CBT_vs_NT <- c(1, 0, 0)
BT_vs_NT <- c(0, 1, 0)
contrasts(ocdData$Group) <- cbind(CBT_vs_NT, BT_vs_NT)
{% endhighlight %}
Note that we're using a non-orthogonal contrast, which means that we cannot look at Type III sums of squares.

#### Create models
The contrasts are not part of MANOVA model, and so we need to create separate linear models for each outcome measure. For Thoughts and Actions, we use

{% highlight r %}
actionModel <- lm(Actions ~ Group, data=ocdData)
thoughtsModel <- lm(Thoughts ~ Group, data=ocdData)
{% endhighlight %}
<small>*Note that the book may have an error here: the author mentioned to use `aov()` function to create the models, but in fact used `lm()` function as above.*</small>

#### Interpret the contrasts
We can interpret the contrasts by:

{% highlight r %}
summary.lm(actionModel)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = Actions ~ Group, data = ocdData)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -2.700 -0.975  0.100  1.075  2.300 
## 
## Coefficients:
##                Estimate Std. Error t value Pr(>|t|)    
## (Intercept)      5.0000     0.4346  11.504 6.47e-12 ***
## GroupCBT_vs_NT  -0.1000     0.6146  -0.163   0.8720    
## GroupBT_vs_NT   -1.3000     0.6146  -2.115   0.0438 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.374 on 27 degrees of freedom
## Multiple R-squared:  0.1703,	Adjusted R-squared:  0.1088 
## F-statistic: 2.771 on 2 and 27 DF,  p-value: 0.08046
{% endhighlight %}



{% highlight r %}
summary.lm(thoughtsModel)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = Thoughts ~ Group, data = ocdData)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
##  -2.40  -1.40  -0.70   1.45   5.00 
## 
## Coefficients:
##                Estimate Std. Error t value Pr(>|t|)    
## (Intercept)     15.0000     0.6722  22.315   <2e-16 ***
## GroupCBT_vs_NT  -1.6000     0.9506  -1.683    0.104    
## GroupBT_vs_NT    0.2000     0.9506   0.210    0.835    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.126 on 27 degrees of freedom
## Multiple R-squared:  0.1376,	Adjusted R-squared:  0.07372 
## F-statistic: 2.154 on 2 and 27 DF,  p-value: 0.1355
{% endhighlight %}
As expected, there is no significant difference. However, in actionModel, there is a significant difference between BT to NT, which is a little unexpected. The author did not explain the reason in the book.

## Conclusion
I only keep the R code and some very brief interpretation of the results. To see the rationale of each method or read more description of each method, it is a good idea to read the book sections. For convenience, I have added section numbers for some methods.

Thanks for reading and feel free to correct me if I made any mistake.

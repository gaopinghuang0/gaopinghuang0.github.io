---
layout: post
title: "Assumptions of Statistics Analysis"
author: "Gaoping Huang"
use_math: true
---

A brief summary of the assumptions of statistic methods from the book "Discovering Statistics using R (2012)" by Andy Field. Most text is directly copied from the book chapter. All the credit goes to him.

To test these assumptions with R, see [Summary of Statistics Methods using R][post_using_R].

## Parametric data
See section 5.3
### 1. Normally distributed data
It means different things in different contexts. See more below.

### 2. Homogeneity of variance
This assumption means that the variances should be the same throughout the data. If you’ve collected groups of data then this means that the variance of your outcome variable or variables should be the same in each of these groups. If you’ve collected continuous data (such as in correlational designs), this assumption means that the variance of one variable should be stable at all levels of the other variable. 

### 3. Interval data
Data should be measured at least at the interval level.

### 4. Independence
This assumption, like that of normality, is different depending on the test you’re using. See more details in each context.
* Data from different participants are independent, which means that the behaviour of one participant does not influence the behaviour of another
* In repeated-measures design, behaviour between different participants should be independent.
* In regression, this assumption also relates to the errors in the regression model being uncorrelated


## Regression
See section 7.7.2.1
### 1. Variable types
All predictor variables must be quantitative or categorical (with two categories), and the outcome variable must be quantitative, continuous and unbounded.

### 2. Non-zero variance
The predictors should have some variation in value (i.e., they do not have variances of 0).

### 3. No perfect multicollinearity
There should be no perfect linear relationship between two or more of the predictors. So, the predictor variables should not correlate too highly (see section 7.7.2.4).

### 4. Predictors are uncorrelated with ‘external variables’
External variables are variables that haven’t been included in the regression model which influence the outcome variable.

### 5. Homoscedasticity
At each level of the predictor variable(s), the variance of the residual terms should be constant. This just means that the residuals at each level of the predictor(s) should have the same variance.

### 6. Independent errors
For any two observations the residual terms should be uncorrelated (or independent). 

### 7. Normally distributed errors
It is assumed that the residuals in the model are random, normally distributed variables with a mean of 0.

### 8. Independence
It is assumed that all of the values of the outcome variable are independent (in other words, each value of the outcome variable comes from a separate entity).

### 9. Linearity
The mean values of the outcome variable for each increment of the predictor(s) lie along a straight line.


## Logistic Regression
See section 8.4. Logistic regression shares some of the assumptions of normal regression: 1) Linearity, 2) Independent errors, and 3) Multicollinearity.

## Comparing two means, t-test
Both independent t-test and the dependent t-test are *parametric tests* mentioned above. The independent t-test, because it is used to test different groups of people, also assumes:
### 1. Independence
Scores in different treatment conditions are independent (because they come from different people).
### 2. Homogeneity of variance
Well, at least in theory we assume equal variances, but in reality we don’t (Jane Superbrain Box 9.2).

## ANOVA
### 1. Homogeneity of variance
### 2. Normality
In terms of normality, what matters is that distributions *within groups* are normally distributed.
### 3. Is ANOVA robust? (section 10.3.2)
* The power of F also appears to be relatively unaffected by non-normality (Donaldson, 1968). This evidence suggests that *when group sizes are equal* the F-statistic can be quite robust to violations of normality.
* Turning to violations of the assumption of homogeneity of variance, ANOVA is fairly robust in terms of the error rate when sample sizes are equal.
* Violations of the **assumption of independence** are very serious indeed.


## ANCOVA

### 1. Independence of the covariate and treatment effect
For example, anxiety and depression are closely correlated (anxious people tend to be depressed) so if you wanted to compare an anxious group of people against a non-anxious group on some task, the chances are that the anxious group would also be more depressed than the non-anxious group. You might think that by adding depression as a covariate into the analysis you can look at the ‘pure’ effect of anxiety, but you can’t.

### 2. Homogeneity of regression slopes
For example, if there’s a positive relationship between the covariate and the outcome in one group, we assume that there is a positive relationship in all of the other groups too.

If you have violated the assumption of homogeneity of regression slopes, or if the variability in regression slopes is an interesting hypothesis in itself, then you can explicitly model this variation using multilevel linear models (see Chapter 19).


## Repeated-measures design

### 1. Sphericity
The assumption of sphericity can be likened to the assumption of homogeneity of variance in *between-group* ANOVA. See section 13.2.1.

Sphericity refers to the equality of variances of the *differences* between treatment levels. So, if you were to take each pair of treatment levels, and calculate the differences between each pair of scores, then it is necessary that these differences have approximately equal variances. As such, *you need at least three conditions for sphericity to be an issue.*

$$Variance_{A–B} ≈ Variance_{A–C} ≈ Variance_{B–C}$$

## Categorical data, chi-square test

### 1. Independence of data
For the chi-square test to be meaningful it is imperative that each person, item or entity contributes to only one cell of the contingency table. Therefore, you cannot use a chi-square test on a repeated-measures design.

### 2. The expected frequencies should be greater than 5.
Although it is acceptable in larger contingency tables to have up to 20% of expected frequencies below 5, the result is a loss of statistical power.

## Conclusion
Again, this post is only a brief summary of the assumptions mentioned in the book. Most text is directly copied from the book chapter. All the credit goes to Andy Field. To validate these assumptions using R, see [Summary of Statistics Methods using R][post_using_R].

[post_using_R]: /2017/11/01/statistics-methods-using-R

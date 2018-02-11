---
layout: post
title: "Exploratory Factor Analysis -- Notes and R Code"
author: "Gaoping Huang"
use_math: true
use_bootstrap: true
---



This post covers my notes of **Exploratory Factor Analysis** methods using R from the book "Discovering Statistics using R (2012)" by Andy Field. Most code and text are directly copied from the book. All the credit goes to him.

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}


## 1. Example of Anxiety Questionnaire
See the screenshot of the questionnaire (copied from the book):
![questionnaire](/assets/figs/anxiety-questionnaire.png)

The questionnaire was designed to predict how anxious a given individual would be about learning how to use R. What’s more, I wanted to know whether anxiety about R could be broken down into specific forms of anxiety. In other words, what latent variables contribute to anxiety about R?

### Sample Size
With a little help from a few lecturer friends I collected 2571 completed questionnaires (at this point it should become apparent that this example is fictitious).

...In short, their study indicated that as communalities become lower the importance of sample size increases. With all communalities above .6, relatively small samples (less than 100) may be perfectly adequate. With communalities in the .5 range, samples between 100 and 200 can be good enough provided there are relatively few factors each with only a small number of indicator variables.

### Correlations between variables
The first thing to do when conducting a factor analysis or principal components analysis is to look at the correlations of the variables.

The correlations between variables can be checked using the `cor()` function to create a correlation matrix of all variables.

There are essentially two potential problems: (1) correlations that are not high enough; and (2) correlations that are too high.

We can test for the first problem by visually scanning the correlation matrix and looking for correlations below about .3: if any variables have lots of correlations below this value then consider excluding them.

For the second problem, if you have reason to believe that the correlation matrix has multicollinearity then you could look through the correlation matrix for variables that correlate very highly (R > .8) and consider eliminating one of the variables (or more) before proceeding.

### Packages to be used

{% highlight r %}
library(corpcor);
library(GPArotation);
library(psych)
{% endhighlight %}

### Load data and calculate correlations

{% highlight r %}
raqData<-read.delim("../assets/Rdata/raq.dat", header = TRUE)
head(raqData)   # only show 6 rows
{% endhighlight %}



{% highlight text %}
##   Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q08 Q09 Q10 Q11 Q12 Q13 Q14 Q15 Q16 Q17 Q18
## 1   4   5   2   4   4   4   3   5   5   4   5   4   4   4   4   3   5   4
## 2   5   5   2   3   4   4   4   4   1   4   4   3   5   3   2   3   4   4
## 3   4   3   4   4   2   5   4   4   4   4   3   3   4   2   4   3   4   3
## 4   3   5   5   2   3   3   2   4   4   2   4   4   4   3   3   3   4   2
## 5   4   5   3   4   4   3   3   4   2   4   4   3   3   4   4   4   4   3
## 6   4   5   3   4   2   2   2   4   2   3   4   2   3   3   1   4   3   1
##   Q19 Q20 Q21 Q22 Q23
## 1   3   4   4   4   1
## 2   3   2   2   2   4
## 3   5   2   3   4   4
## 4   4   2   2   2   3
## 5   3   2   4   2   2
## 6   5   1   3   5   2
{% endhighlight %}



{% highlight r %}
raqMatrix <- cor(raqData)
head(round(raqMatrix, 2))
{% endhighlight %}



{% highlight text %}
##       Q01   Q02   Q03   Q04   Q05   Q06   Q07   Q08   Q09   Q10   Q11
## Q01  1.00 -0.10 -0.34  0.44  0.40  0.22  0.31  0.33 -0.09  0.21  0.36
## Q02 -0.10  1.00  0.32 -0.11 -0.12 -0.07 -0.16 -0.05  0.31 -0.08 -0.14
## Q03 -0.34  0.32  1.00 -0.38 -0.31 -0.23 -0.38 -0.26  0.30 -0.19 -0.35
## Q04  0.44 -0.11 -0.38  1.00  0.40  0.28  0.41  0.35 -0.12  0.22  0.37
## Q05  0.40 -0.12 -0.31  0.40  1.00  0.26  0.34  0.27 -0.10  0.26  0.30
## Q06  0.22 -0.07 -0.23  0.28  0.26  1.00  0.51  0.22 -0.11  0.32  0.33
##       Q12   Q13   Q14   Q15   Q16   Q17   Q18   Q19   Q20   Q21   Q22
## Q01  0.35  0.35  0.34  0.25  0.50  0.37  0.35 -0.19  0.21  0.33 -0.10
## Q02 -0.19 -0.14 -0.16 -0.16 -0.17 -0.09 -0.16  0.20 -0.20 -0.20  0.23
## Q03 -0.41 -0.32 -0.37 -0.31 -0.42 -0.33 -0.38  0.34 -0.32 -0.42  0.20
## Q04  0.44  0.34  0.35  0.33  0.42  0.38  0.38 -0.19  0.24  0.41 -0.10
## Q05  0.35  0.30  0.32  0.26  0.39  0.31  0.32 -0.17  0.20  0.33 -0.13
## Q06  0.31  0.47  0.40  0.36  0.24  0.28  0.51 -0.17  0.10  0.27 -0.17
##       Q23
## Q01  0.00
## Q02  0.10
## Q03  0.15
## Q04 -0.03
## Q05 -0.04
## Q06 -0.07
{% endhighlight %}
If got warning message about non-positive definite matrix, then check the R's Souls' Tip 17.1.

First, scan the matrix for correlations greater than .3, then look for variables that only have a small number of correlations greater than this value. Then scan the correlation coefficients themselves and look for any greater than .9. If any are found then you should be aware that a problem could arise because of multicollinearity in the data.

Then, run Bartlett's test on the correlation matrix by using `cortest.bartlett()` from `psych` package.

{% highlight r %}
cortest.bartlett(raqData)
{% endhighlight %}



{% highlight text %}
## $chisq
## [1] 19334.49
## 
## $p.value
## [1] 0
## 
## $df
## [1] 253
{% endhighlight %}



{% highlight r %}
# or
# cortest.bartlett(raqMatrix, n=2571)
{% endhighlight %}
For these data, Bartlett’s test is highly significant, χ2(253) = 19,334, p < .001, and therefore factor analysis is appropriate.

Then, we could get the determinant:

{% highlight r %}
det(raqMatrix)
{% endhighlight %}



{% highlight text %}
## [1] 0.0005271037
{% endhighlight %}
This value is greater than the necessary value of 0.00001 (see section 17.5). As such, our determinant does not seem problematic. 

### Factor extraction, here PCA
For our present purposes we will use *principal components analysis* (PCA), which strictly speaking isn’t factor analysis; however, the two procedures may often yield similar results. Principal component analysis is carried out using the `principal()` function in the `psych` package.

{% highlight r %}
pc1 <- principal(raqData, nfactors=23, rotate="none")
# pc1 has two columns, h2 and u2
{% endhighlight %}
h2 is the communalities, for now, all are 1; u2 is the uniqueness or unique variance, it's 1 minus the communality, for now, all are 0

#### Scree Plot
The eigenvalues are stored in a variable called `pc1$values`

{% highlight r %}
plot(pc1$values, type="b")   # type="b" will show both the line and the points
{% endhighlight %}

![plot of chunk scree_plot](/assets/Rfig/exploratory-factor-scree_plot-1.svg)
From the scree plot, we could find the point of inflexion (around the third point to the left). The evidence from the scree plot and from the eigenvalues suggests a *four-component* solution may be the best.

#### Redo PCA
Now that we know how many components we want to extract, we can rerun the analysis, specifying that number. To do this, we use an identical command to the previous model but we change nfactors = 23 to be nfactors = 4 because we now want only four factors.

{% highlight r %}
pc2 <- principal(raqData, nfactors=4, rotate="none")
{% endhighlight %}
The communalities (the h2 column) and uniquenesses (the u2 column) are changed. Remember that the communality is the proportion of common variance within a variable

Now that we have the communalities, we can go back to Kaiser’s criterion to see whether we still think that four factors should have been extracted.  (Skipped here)

#### Reproduced correlation matrix + difference between the reproduced cor matrix and the original cor matrix
The reproduced correlations are obtained with the `factor.model()` function.

The difference between the reproduced and actual correlation matrices is referred to as the residuals, and these are obtained with the `factor.residuals()` function.


{% highlight r %}
# factor.model(pc2$loadings)
residuals<-factor.residuals(raqMatrix, pc2$loadings)
{% endhighlight %}

One approach to looking at residuals is just to say that we want the residuals to be small. In fact, we want most values to be less than 0.05. We need to create a new object to see it more easily.

{% highlight r %}
residuals<-as.matrix(residuals[upper.tri(residuals)])
{% endhighlight %}
This command re-creates the object `residuals` by using only the upper triangle of the original matrix. We now have an object called `residuals` that contains the residuals stored in a column. This is handy because it makes it easy to calculate various things.

{% highlight r %}
large.resid<-abs(residuals) > 0.05
# proportion of the large residuals
sum(large.resid)/nrow(residuals)
{% endhighlight %}



{% highlight text %}
## [1] 0.3596838
{% endhighlight %}
Some other residuals stats, such as the mean, are skipped here.

### Rotation
#### Orthogonal rotation (varimax)
We can set `rotate="varimax"` in the `principal()` function. But there are too many things to see.

`print.psych()` command prints the factor loading matrix associated with the model `pc3`, but displaying only loadings above .3 (cut = 0.3) and sorting items by the size of their loadings (sort = TRUE).

{% highlight r %}
pc3 <- principal(raqData, nfactors=4, rotate="varimax")
print.psych(pc3, cut = 0.3, sort = TRUE)
{% endhighlight %}



{% highlight text %}
## Principal Components Analysis
## Call: principal(r = raqData, nfactors = 4, rotate = "varimax")
## Standardized loadings (pattern matrix) based upon correlation matrix
##     item   RC3   RC1   RC4   RC2   h2   u2 com
## Q06    6  0.80                   0.65 0.35 1.0
## Q18   18  0.68  0.33             0.60 0.40 1.5
## Q13   13  0.65                   0.54 0.46 1.6
## Q07    7  0.64  0.33             0.55 0.45 1.7
## Q14   14  0.58  0.36             0.49 0.51 1.8
## Q10   10  0.55                   0.33 0.67 1.2
## Q15   15  0.46                   0.38 0.62 2.6
## Q20   20        0.68             0.48 0.52 1.1
## Q21   21        0.66             0.55 0.45 1.5
## Q03    3       -0.57        0.37 0.53 0.47 2.3
## Q12   12  0.47  0.52             0.51 0.49 2.1
## Q04    4  0.32  0.52  0.31       0.47 0.53 2.4
## Q16   16  0.33  0.51  0.31       0.49 0.51 2.6
## Q01    1        0.50  0.36       0.43 0.57 2.4
## Q05    5  0.32  0.43             0.34 0.66 2.5
## Q08    8              0.83       0.74 0.26 1.1
## Q17   17              0.75       0.68 0.32 1.5
## Q11   11              0.75       0.69 0.31 1.5
## Q09    9                    0.65 0.48 0.52 1.3
## Q22   22                    0.65 0.46 0.54 1.2
## Q23   23                    0.59 0.41 0.59 1.4
## Q02    2       -0.34        0.54 0.41 0.59 1.7
## Q19   19       -0.37        0.43 0.34 0.66 2.2
## 
##                        RC3  RC1  RC4  RC2
## SS loadings           3.73 3.34 2.55 1.95
## Proportion Var        0.16 0.15 0.11 0.08
## Cumulative Var        0.16 0.31 0.42 0.50
## Proportion Explained  0.32 0.29 0.22 0.17
## Cumulative Proportion 0.32 0.61 0.83 1.00
## 
## Mean item complexity =  1.8
## Test of the hypothesis that 4 components are sufficient.
## 
## The root mean square of the residuals (RMSR) is  0.06 
##  with the empirical chi square  4006.15  with prob <  0 
## 
## Fit based upon off diagonal values = 0.96
{% endhighlight %}
According to the results and the [screenshot of questionnaires](#1-example-of-anxiety-questionnaire) above, we could find the questions that load highly on factor 1 are Q6 ("I have little experience of computers") with the highest loading of .80, Q18 ("R always crashes when I try to use it"), Q13 ("I worry I will cause irreparable damage ..."), Q7 ("All computers hate me"), Q14 ("Computers have minds of their own ..."), Q10 ("Computers are only for games"), and Q15 ("Computers are out to get me") with the lowest loading of .46. All these items seem to relate to using computers or R. Therefore we might label this factor *fear of computers*.

Similarly, we might label the factor 2 as *fear of statistics*, factor 3 *fear of mathematics*, and factor 4 *peer evaluation*.

#### Oblique rotation (skipped)

### Factor scores
By setting `scores=TRUE`:

{% highlight r %}
pc5 <- principal(raqData, nfactors = 4, rotate = "oblimin", scores = TRUE)
# head(pc5$scores)    # access scores by pc5$scores
raqData <- cbind(raqData, pc5$scores)
# bind the factor scores to raqData dataframe for other use
{% endhighlight %}

### Report factor analysis (skipped)

### Reliability analysis
If you’re using factor analysis to validate a questionnaire, it is useful to check the reliability of your scale.

Reliability means that a measure (or in this case questionnaire) should consistently reflect the construct that it is measuring. One way to think of this is that, other things being equal, a person should get the same score on a questionnaire if they complete it at two different points in time (we have already discovered that this is called *test–retest reliability*).

The simplest way to do this in practice is to use `split-half reliability`. This method randomly splits the data set into two. A score for each participant is then calculated based on each half of the scale. If a scale is very reliable a person’s score on one half of the scale should be the same (or similar) to their score on the other half: two halves should correlate very highly.

#### Cronbach's alpha, α
This method is loosely equivalent to splitting data in two in every possible way and computing the correlation coefficient for each split, and then compute the average of these values.

Recall that we have four factors: fear of computers, fear of statistics, fear of mathematics, and peer evaluation. Each factor stands for several questions in the questionnaire. For example, fear of computers includes question 6, 7, 10, ..., 18.


{% highlight r %}
computerFear<-raqData[, c(6, 7, 10, 13, 14, 15, 18)]
statisticsFear <- raqData[, c(1, 3, 4, 5, 12, 16, 20, 21)]
mathFear <- raqData[, c(8, 11, 17)]
peerEvaluation <- raqData[, c(2, 9, 19, 22, 23)]
{% endhighlight %}
Reliability analysis is done with the `alpha()` function, which is found in the `psych` package.

So for `computerFear`, which has only positively scored items, we would use:

{% highlight r %}
keys = c(1, 1, 1, 1, 1, 1, 1)
{% endhighlight %}
but for `statisticsFear`, which has item 3 (Question 3, the negatively scored item) as its second item, we would use:

{% highlight r %}
keys = c(1, -1, 1, 1, 1, 1, 1, 1)
{% endhighlight %}

{% highlight r %}
alpha(computerFear)
{% endhighlight %}



{% highlight text %}
## 
## Reliability analysis   
## Call: alpha(x = computerFear)
## 
##   raw_alpha std.alpha G6(smc) average_r S/N    ase mean   sd
##       0.82      0.82    0.81       0.4 4.6 0.0052  3.4 0.71
## 
##  lower alpha upper     95% confidence boundaries
## 0.81 0.82 0.83 
## 
##  Reliability if an item is dropped:
##     raw_alpha std.alpha G6(smc) average_r S/N alpha se
## Q06      0.79      0.79    0.77      0.38 3.7   0.0063
## Q07      0.79      0.79    0.77      0.38 3.7   0.0063
## Q10      0.82      0.82    0.80      0.44 4.7   0.0053
## Q13      0.79      0.79    0.77      0.39 3.8   0.0062
## Q14      0.80      0.80    0.77      0.39 3.9   0.0060
## Q15      0.81      0.81    0.79      0.41 4.2   0.0056
## Q18      0.79      0.78    0.76      0.38 3.6   0.0064
## 
##  Item statistics 
##        n raw.r std.r r.cor r.drop mean   sd
## Q06 2571  0.75  0.74  0.68   0.62  3.8 1.12
## Q07 2571  0.75  0.73  0.68   0.62  3.1 1.10
## Q10 2571  0.54  0.57  0.44   0.40  3.7 0.88
## Q13 2571  0.72  0.73  0.67   0.61  3.6 0.95
## Q14 2571  0.70  0.70  0.64   0.58  3.1 1.00
## Q15 2571  0.64  0.64  0.54   0.49  3.2 1.01
## Q18 2571  0.76  0.76  0.72   0.65  3.4 1.05
## 
## Non missing response frequency for each item
##        1    2    3    4    5 miss
## Q06 0.06 0.10 0.13 0.44 0.27    0
## Q07 0.09 0.24 0.26 0.34 0.07    0
## Q10 0.02 0.10 0.18 0.57 0.14    0
## Q13 0.03 0.12 0.25 0.48 0.12    0
## Q14 0.07 0.18 0.38 0.31 0.06    0
## Q15 0.06 0.18 0.30 0.39 0.07    0
## Q18 0.06 0.12 0.31 0.37 0.14    0
{% endhighlight %}



{% highlight r %}
# alpha(statisticsFear, keys = c(1, -1, 1, 1, 1, 1, 1, 1))
# alpha(mathFear)
# alpha(peerEvaluation)
{% endhighlight %}
To reiterate, we’re looking for values in the range of .7 to .8 (or thereabouts) bearing in mind what we’ve already noted about effects from the number of items.

In this case, α of `computerFear` is slightly above .8, and is certainly in the region indicated by Kline (1999), so this probably indicates good reliability.

`r.drop` is the correlation of that item with the scale total if that item isn’t included in the scale total. If any of these values of `r.drop` are less than about .3 then we’ve got problems, because it means that a particular item does not correlate very well with the scale overall. 

In this case, all data are above .3, which is encouraging.

The analysis of other three factors is very similar and thus skipped.

#### Report reliability analysis (skipped)

## 2. Questions

* What is loading?

* How to compute loading?

* What is a Factor?

* What is communality?

* How to compute communality?



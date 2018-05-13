---
layout: post
title: "Factorial ANOVA -- Notes and R Code"
author: "Gaoping Huang"
tags: R
use_math: true
use_bootstrap: true
---



This post covers my notes of **factorial ANOVA** methods using R from the book "Discovering Statistics using R (2012)" by Andy Field. Most code and text are directly copied from the book. All the credit goes to him.

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

## 1. Enter data

{% highlight r %}
gogglesData<-read.csv("../assets/Rdata/goggles.csv", header = TRUE)
gogglesData$alcohol<-factor(gogglesData$alcohol, 
    levels = c("None", "2 Pints", "4 Pints"))
{% endhighlight %}

## 2. Explore your data

### Self-test 2  (note that self-test 1 is moved to the later part)
Use ggplot2 to plot boxplots of the attractiveness of the date at each level of alcohol consumption on the x-axis and different panels to represent males and females.


{% highlight r %}
library(ggplot2)
boxplot <- ggplot(gogglesData, aes(alcohol, attractiveness))
boxplot + geom_boxplot() + facet_wrap(~gender) + labs(x="alcohol", y ="attractiveness (%)")
{% endhighlight %}

![plot of chunk self_test_2](/assets/Rfig/factorial-ANOVA-notes-self_test_2-1.svg)

### stat.desc for combinations of levels of variables
{% include toggle_button.html target="collapseStatDesc" %}
<div markdown="1" class="collapse" id="collapseStatDesc">

{% highlight r %}
library(pastecs)
# by(gogglesData$attractiveness, gogglesData$gender, stat.desc)
# by(gogglesData$attractiveness, gogglesData$alcohol, stat.desc)
by(gogglesData$attractiveness, list(gogglesData$alcohol, gogglesData$gender), stat.desc)
{% endhighlight %}



{% highlight text %}
## : None
## : Female
##      nbr.val     nbr.null       nbr.na          min          max 
##        8.000        0.000        0.000       55.000       70.000 
##        range          sum       median         mean      SE.mean 
##       15.000      485.000       60.000       60.625        1.752 
## CI.mean.0.95          var      std.dev     coef.var 
##        4.143       24.554        4.955        0.082 
## -------------------------------------------------------- 
## : 2 Pints
## : Female
##      nbr.val     nbr.null       nbr.na          min          max 
##          8.0          0.0          0.0         50.0         70.0 
##        range          sum       median         mean      SE.mean 
##         20.0        500.0         62.5         62.5          2.3 
## CI.mean.0.95          var      std.dev     coef.var 
##          5.5         42.9          6.5          0.1 
## -------------------------------------------------------- 
## : 4 Pints
## : Female
##      nbr.val     nbr.null       nbr.na          min          max 
##         8.00         0.00         0.00        50.00        70.00 
##        range          sum       median         mean      SE.mean 
##        20.00       460.00        55.00        57.50         2.50 
## CI.mean.0.95          var      std.dev     coef.var 
##         5.91        50.00         7.07         0.12 
## -------------------------------------------------------- 
## : None
## : Male
##      nbr.val     nbr.null       nbr.na          min          max 
##         8.00         0.00         0.00        50.00        80.00 
##        range          sum       median         mean      SE.mean 
##        30.00       535.00        67.50        66.88         3.65 
## CI.mean.0.95          var      std.dev     coef.var 
##         8.64       106.70        10.33         0.15 
## -------------------------------------------------------- 
## : 2 Pints
## : Male
##      nbr.val     nbr.null       nbr.na          min          max 
##         8.00         0.00         0.00        45.00        85.00 
##        range          sum       median         mean      SE.mean 
##        40.00       535.00        67.50        66.88         4.43 
## CI.mean.0.95          var      std.dev     coef.var 
##        10.47       156.70        12.52         0.19 
## -------------------------------------------------------- 
## : 4 Pints
## : Male
##      nbr.val     nbr.null       nbr.na          min          max 
##          8.0          0.0          0.0         20.0         55.0 
##        range          sum       median         mean      SE.mean 
##         35.0        285.0         32.5         35.6          3.8 
## CI.mean.0.95          var      std.dev     coef.var 
##          9.1        117.4         10.8          0.3
{% endhighlight %}
</div>

### Levene's test on interaction
{% include toggle_button.html target="collapseLeveneTest" %}
<div markdown="1" class="collapse" id="collapseLeveneTest">

{% highlight r %}
library(car)
# leveneTest(gogglesData$attractiveness, gogglesData$gender, center = median)
# leveneTest(gogglesData$attractiveness, gogglesData$alcohol, center = median)
leveneTest(gogglesData$attractiveness, interaction(gogglesData$alcohol, gogglesData$gender), center = median)
{% endhighlight %}



{% highlight text %}
## Levene's Test for Homogeneity of Variance (center = median)
##       Df F value Pr(>F)
## group  5    1.43   0.24
##       42
{% endhighlight %}
We have F(5, 42) = 1.425, p = .235, which is indicative of the assumption being met.
</div>

## 3. Choose contrasts
One very important consideration here is that if we want to look at Type III sums of squares (see Jane Superbrain Box 11.1) then *we must use an orthogonal contrast for these sums of squares to be computed correctly.*


{% highlight r %}
contrasts(gogglesData$alcohol)<-cbind(c(-2, 1, 1), c(0, -1, 1))
contrasts(gogglesData$gender)<-c(-1, 1)
{% endhighlight %}
{% include toggle_button.html target="collapseContrast" %}
<div markdown="1" class="collapse" id="collapseContrast">

{% highlight r %}
gogglesData$alcohol
{% endhighlight %}



{% highlight text %}
##  [1] None    None    None    None    None    None    None    None   
##  [9] 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints
## [17] 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints
## [25] None    None    None    None    None    None    None    None   
## [33] 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints 2 Pints
## [41] 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints 4 Pints
## attr(,"contrasts")
##         [,1] [,2]
## None      -2    0
## 2 Pints    1   -1
## 4 Pints    1    1
## Levels: None 2 Pints 4 Pints
{% endhighlight %}



{% highlight r %}
gogglesData$gender
{% endhighlight %}



{% highlight text %}
##  [1] Female Female Female Female Female Female Female Female Female Female
## [11] Female Female Female Female Female Female Female Female Female Female
## [21] Female Female Female Female Male   Male   Male   Male   Male   Male  
## [31] Male   Male   Male   Male   Male   Male   Male   Male   Male   Male  
## [41] Male   Male   Male   Male   Male   Male   Male   Male  
## attr(,"contrasts")
##        [,1]
## Female   -1
## Male      1
## Levels: Female Male
{% endhighlight %}
</div>

## 4. Do the factorial ANOVA

{% highlight r %}
gogglesModel<-aov(attractiveness ~ gender + alcohol + gender:alcohol, data = gogglesData)
{% endhighlight %}
This command creates a model called `gogglesModel`, which includes the two independent variables and their interaction.

{% highlight r %}
Anova(gogglesModel, type="III")
{% endhighlight %}



{% highlight text %}
## Anova Table (Type III tests)
## 
## Response: attractiveness
##                Sum Sq Df F value  Pr(>F)    
## (Intercept)    163333  1 1967.03 < 2e-16 ***
## gender            169  1    2.03    0.16    
## alcohol          3332  2   20.07 7.6e-07 ***
## gender:alcohol   1978  2   11.91 8.0e-05 ***
## Residuals        3488 42                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}
**Output 1**

## 5. Interpret factorial ANOVA
Output 1 tells us that there is a significant main effect of **alcohol** (p<0.05). It also tells us that the main effect of **gender** is not significant (p=0.16). Finally, it tells us that the interaction between the effect of **gender** and the effect of **alcohol** is significant.

### Self-test 3
Plot error bar graphs of the main effects of alcohol and gender.

{% highlight r %}
bar_alcohol <- ggplot(gogglesData, aes(alcohol, attractiveness))
bar_alcohol + stat_summary(fun.y = mean, geom = "bar", fill = "White", colour = "Black") +
    stat_summary(fun.data = mean_cl_normal, geom = "pointrange") + 
    labs(x = "Alcohol Consumption", y = "Mean Attractiveness of Date (%)") + 
    scale_y_continuous(breaks=seq(0, 80, by = 10))
{% endhighlight %}

![plot of chunk self_test_3](/assets/Rfig/factorial-ANOVA-notes-self_test_3-1.svg)

{% highlight r %}
bar_gender <- ggplot(gogglesData, aes(gender, attractiveness))
bar_gender + stat_summary(fun.y = mean, geom = "bar", fill = "White", colour = "Black") +
    stat_summary(fun.data = mean_cl_normal, geom = "pointrange") + 
    labs(x = "Gender", y = "Mean Attractiveness of Date (%)") + 
    scale_y_continuous(breaks=seq(0,80, by = 10))
{% endhighlight %}

![plot of chunk self_test_3](/assets/Rfig/factorial-ANOVA-notes-self_test_3-2.svg)
> Note that I’ve used `scale_y_continuous()` to override the defaults for the y-axis. Specifically, I have used the breaks option to specify the numbering along this axis: `breaks=seq(0, 80, by = 10)` uses the `seq()` function to create a sequence of numbers from 0 to 80 in steps of 10. Therefore, we get axis labels at 0, 10, 20, 30, 40, 50, 60, 70, 80 (the defaults were 0, 20, 40, 60, 80).

### Self-test 1
Use ggplot2 to plot a line graph (with error bars) of the attractiveness of the date with alcohol consumption on the x-axis and different-coloured lines to represent males and females.


{% highlight r %}
line <- ggplot(gogglesData, aes(alcohol, attractiveness, colour = gender))
line + stat_summary(fun.y = mean, geom = "point") + 
    stat_summary(fun.y = mean, geom = "line", aes(group= gender)) +
    stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.2) + 
    labs(x = "Alcohol Consumption", y = "Mean Attractiveness of Date (%)", colour = "Gender")
{% endhighlight %}

![plot of chunk self_test_1](/assets/Rfig/factorial-ANOVA-notes-self_test_1-1.svg)
This figure shows that for women, alcohol has very little effect: the attractiveness of their selected partners is quite stable across the three conditions (as shown by the near-horizontal line). However, for the men, the attractiveness of their partners is stable when only a small amount has been drunk, but rapidly declines when 4 pints have been drunk.

### Short summary of the three plots 
This shows why main effects should not be interpretted when a significant interaction involving those main effects exists.


## 6. Interpret contrasts

{% highlight r %}
summary.lm(gogglesModel)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## aov(formula = attractiveness ~ gender + alcohol + gender:alcohol, 
##     data = gogglesData)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -21.875  -5.625  -0.625   5.156  19.375 
## 
## Coefficients:
##                  Estimate Std. Error t value Pr(>|t|)    
## (Intercept)         58.33       1.31   44.35  < 2e-16 ***
## gender1             -1.88       1.31   -1.43   0.1614    
## alcohol1            -2.71       0.93   -2.91   0.0057 ** 
## alcohol2            -9.06       1.61   -5.63  1.4e-06 ***
## gender1:alcohol1    -2.50       0.93   -2.69   0.0103 *  
## gender1:alcohol2    -6.56       1.61   -4.07   0.0002 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 9.1 on 42 degrees of freedom
## Multiple R-squared:  0.611,	Adjusted R-squared:  0.565 
## F-statistic: 13.2 on 5 and 42 DF,  p-value: 9.61e-08
{% endhighlight %}
- **gender1**: This is the contrast for the main effect of gender
- **alcohol1**: This contrast compares the no-alcohol group to the two alcohol groups.
- **alcohol2**: This contrast tests whether the mean of the 2-pints group (64.69) is different than the mean of the 4-pints group (46.56).
- **gender1:alcohol1**: This contrast tests whether the effect of **alcohol1** described above is different in men and women.
- **gender1:alcohol2**: This contrast tests whether the effect of **alcohol2** described above is different in men and women.

## 7. Simple effects analysis - break down an interaction term (skipped)
This analysis looks at the effect of one independent variable at individual levels of the other independent variable. So, for example, in our beer-goggles data we could do simple effects analysis looking at the effect of gender at each level of alcohol. This would mean taking the average attractiveness of the date selected by men and comparing it to that for women after no drinks, then making the same comparison for 2 pints and then finally for 4 pints.

(skipped)

## 8. *Post hoc* test (for illustrative purposes)
The variable **alcohol** has three levels and so you might want to perform post hoc tests to see where the differences between groups lie.

However, since the interaction between alcohol and gender is significant, we should not interpret alcohol alone.

Therefore, this post hoc test is for illustrative purposes.

Bonferroni post hoc tests using the `pairwise.t.test()` function and Tukey tests using `glht()`:
{% include toggle_button.html target="collapsePostHoc" %}
<div markdown="1" class="collapse" id="collapsePostHoc">

{% highlight r %}
library(multcomp)
pairwise.t.test(gogglesData$attractiveness, gogglesData$alcohol, 
    p.adjust.method = "bonferroni")
{% endhighlight %}



{% highlight text %}
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  gogglesData$attractiveness and gogglesData$alcohol 
## 
##         None  2 Pints
## 2 Pints 1     -      
## 4 Pints 2e-04 1e-04  
## 
## P value adjustment method: bonferroni
{% endhighlight %}



{% highlight r %}
postHocs<-glht(gogglesModel, linfct = mcp(alcohol = "Tukey"))
summary(postHocs)
{% endhighlight %}



{% highlight text %}
## 
## 	 Simultaneous Tests for General Linear Hypotheses
## 
## Multiple Comparisons of Means: Tukey Contrasts
## 
## 
## Fit: aov(formula = attractiveness ~ gender + alcohol + gender:alcohol, 
##     data = gogglesData)
## 
## Linear Hypotheses:
##                        Estimate Std. Error t value Pr(>|t|)    
## 2 Pints - None == 0       0.938      3.222    0.29     0.95    
## 4 Pints - None == 0     -17.188      3.222   -5.33   <1e-05 ***
## 4 Pints - 2 Pints == 0  -18.125      3.222   -5.63   <1e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## (Adjusted p values reported -- single-step method)
{% endhighlight %}



{% highlight r %}
confint(postHocs)
{% endhighlight %}



{% highlight text %}
## 
## 	 Simultaneous Confidence Intervals
## 
## Multiple Comparisons of Means: Tukey Contrasts
## 
## 
## Fit: aov(formula = attractiveness ~ gender + alcohol + gender:alcohol, 
##     data = gogglesData)
## 
## Quantile = 2.4
## 95% family-wise confidence level
##  
## 
## Linear Hypotheses:
##                        Estimate lwr     upr    
## 2 Pints - None == 0      0.938   -6.887   8.762
## 4 Pints - None == 0    -17.188  -25.012  -9.363
## 4 Pints - 2 Pints == 0 -18.125  -25.950 -10.300
{% endhighlight %}
The Bonferroni and Tukey tests show the same pattern of results: when participants had drunk no alcohol or 2 pints of alcohol, they selected equally attractive mates. However, after 4 pints had been consumed, participants selected significantly less attractive mates than after both 2 pints (p < .001) and no alcohol (p < .001).
</div>

### Plots
`aov()` function automatically generates some plots that we can use to test the assumptions. We can see these graphs by executing:

{% highlight r %}
plot(gogglesModel)
{% endhighlight %}

<img src="/assets/Rfig/factorial-ANOVA-notes-residual_by_plot-1.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/factorial-ANOVA-notes-residual_by_plot-2.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/factorial-ANOVA-notes-residual_by_plot-3.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/factorial-ANOVA-notes-residual_by_plot-4.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" />
You will actually see four graphs, but the first two are the most important. The first graph (on the left of the figure) can be used for testing homogeneity of variance. The plot we have does show funnelling (the spread of scores is wider at some points than at others), which implies that the residuals might be heteroscedastic (a bad thing). The second plot (on the right) is a Q-Q plot, which tells us about the normality of residuals in the model. Our plot suggests that we can assume normality of our residuals/errors.

## Robust test (skipped)
The residual plot above suggests that a robust test might be in order. However, it has many steps and functions. I'd like to skip this method.

## Effect size
- Omega squared ($\omega^2$). This measure computes the overall effect size. Section 12.8 provides a `omega_factorial()` function. 
- `mes()`, compute effect sizes for the effect of gender at different levels of alcohol. I'd like to skip this method.

## Conclusion
I only keep the R code and some very brief interpretation of the results. To see the rationale of each method or read more description of each method, it is a good idea to read the book sections. For convenience, I have added section numbers for some methods.

Thanks for reading and feel free to correct me if I made any mistake.

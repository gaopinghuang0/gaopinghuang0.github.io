---
layout: post
title: "ANCOVA -- Notes and R Code"
author: "Gaoping Huang"
use_math: true
use_bootstrap: false
---



This post covers my notes of ANCOVA methods using R from the book "Discovering Statistics using R (2012)" by Andy Field. Most code and text are directly copied from the book. All the credit goes to him.


* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

## 0a. What is ANCOVA?
ANCOVA extends ANOVA by including **covariates** into the analysis. Covariates mean continuous variables that are not part of the main experimental manipulation but have an influence on the dependent variable.

There are two reasons for including covariates: 
* **To reduce within-group error variance:**  If we can explain some of the ‘unexplained’ variance ($ SS_R $) in terms of other variables (covariates), then we reduce the error variance, allowing us to more accurately assess the effect of the independent variable ($ SS_M $).
* **Elimination of confounds:** In any experiment, there may be unmeasured variables that confound the results (i.e., variables other than the experimental manipulation that affect the outcome variable). If any variables are known to influence the dependent variable being measured, then ANCOVA is ideally suited to remove the bias of these variables. Once a possible confounding variable has been identified, it can be measured and entered into the analysis as a covariate.

## 0b. Assumptions
It is a part of my another post [Assumptions of statistics methods](/2017/11/01/assumptions-of-statistics-methods).

### Independence of the covariate and treatment effect
For example, anxiety and depression are closely correlated (anxious people tend to be depressed) so if you wanted to compare an anxious group of people against a non-anxious group on some task, the chances are that the anxious group would also be more depressed than the non-anxious group. You might think that by adding depression as a covariate into the analysis you can look at the ‘pure’ effect of anxiety, but you can’t.

### Homogeneity of regression slopes
For example, if there’s a positive relationship between the covariate and the outcome in one group, we assume that there is a positive relationship in all of the other groups too.

If you have violated the assumption of homogeneity of regression slopes, or if the variability in regression slopes is an interesting hypothesis in itself, then you can explicitly model this variation using multilevel linear models (see Chapter 19).


## 1. Enter data

{% highlight r %}
viagraData <- read.delim("../assets/Rdata/ViagraCovariate.dat", header = TRUE)
viagraData$dose <- factor(viagraData$dose, levels = c(1:3),
    labels = c("Placebo", "Low Dose", "High Dose"))
str(viagraData)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	30 obs. of  3 variables:
##  $ dose         : Factor w/ 3 levels "Placebo","Low Dose",..: 1 1 1 1 1 1 1 1 1 2 ...
##  $ libido       : int  3 2 5 2 2 2 7 2 4 7 ...
##  $ partnerLibido: int  4 1 5 1 2 2 7 4 5 5 ...
{% endhighlight %}


## 2. Explore your data
### Self-test 1
Use R to find out the means and standard deviations of both the participant’s libido and the partner’s libido in the three groups.


{% highlight r %}
library(pastecs)
options(digits=2)  # round output to 2 digits
by(viagraData$libido, viagraData$dose, stat.desc, basic=F)
{% endhighlight %}



{% highlight text %}
## viagraData$dose: Placebo
##       median         mean      SE.mean CI.mean.0.95          var 
##         2.00         3.22         0.60         1.37         3.19 
##      std.dev     coef.var 
##         1.79         0.55 
## -------------------------------------------------------- 
## viagraData$dose: Low Dose
##       median         mean      SE.mean CI.mean.0.95          var 
##         4.50         4.88         0.52         1.22         2.12 
##      std.dev     coef.var 
##         1.46         0.30 
## -------------------------------------------------------- 
## viagraData$dose: High Dose
##       median         mean      SE.mean CI.mean.0.95          var 
##         4.00         4.85         0.59         1.28         4.47 
##      std.dev     coef.var 
##         2.12         0.44
{% endhighlight %}



{% highlight r %}
by(viagraData$partnerLibido, viagraData$dose, stat.desc, basic=F)
{% endhighlight %}



{% highlight text %}
## viagraData$dose: Placebo
##       median         mean      SE.mean CI.mean.0.95          var 
##         4.00         3.44         0.69         1.59         4.28 
##      std.dev     coef.var 
##         2.07         0.60 
## -------------------------------------------------------- 
## viagraData$dose: Low Dose
##       median         mean      SE.mean CI.mean.0.95          var 
##         2.50         3.12         0.61         1.44         2.98 
##      std.dev     coef.var 
##         1.73         0.55 
## -------------------------------------------------------- 
## viagraData$dose: High Dose
##       median         mean      SE.mean CI.mean.0.95          var 
##         2.00         2.00         0.45         0.99         2.67 
##      std.dev     coef.var 
##         1.63         0.82
{% endhighlight %}
Use `basic=F` to remove some desciptives that don't interest us.

### Self-test 2
Use *ggplot2* to produce boxplots for the Viagra data. Try to re-create Figure 11.4.

The data are currently in wide format, but we need them in long format, so we create a new datafile called `restructuredData` that has the data in the correct format using the `melt()` function from the *reshape2* package

{% highlight r %}
library(reshape2)
restructuredData<-melt(viagraData, id=c("dose"), measured=c("libido", "partnerLibido"))
names(restructuredData)<-c("dose", "libido_type", "libido")

# draw boxplot
library(ggplot2)
boxplot <- ggplot(restructuredData, aes(dose, libido))
boxplot + geom_boxplot() + facet_wrap(~libido_type) + labs(x="Dose", y ="Libido")
{% endhighlight %}

![plot of chunk self_test_2](/assets/Rfig/ANCOVA-notes-self_test_2-1.svg)
Levels of libido seem to increase for participants as the dose of Viagra increases but the opposite is true for their partners. Also, the spread of scores is more variable for the participants than their partners.

### Levene's test

{% highlight r %}
library(car)
leveneTest(viagraData$libido, viagraData$dose, center = median)
{% endhighlight %}



{% highlight text %}
## Levene's Test for Homogeneity of Variance (center = median)
##       Df F value Pr(>F)
## group  2    0.33   0.72
##       27
{% endhighlight %}
The output shows that Levene’s test is very non-significant, F(2, 27) = 0.33, p = .72. This means that for these data the variances are very similar.

## 3. Check that the covariate and any independent variables are independent

### Self-test 3
Conduct an ANOVA to test whether partner’s libido (our covariate) is independent of the dose of Viagra (our independent variable).

{% highlight r %}
viagraModel.1<-aov(partnerLibido ~ dose, data = viagraData)
summary(viagraModel.1)
{% endhighlight %}



{% highlight text %}
##             Df Sum Sq Mean Sq F value Pr(>F)
## dose         2   12.8    6.38    1.98   0.16
## Residuals   27   87.1    3.23
{% endhighlight %}
The main effect of dose is not significant, F(2, 27) = 1.98, p = .16, which shows that the average level of partner’s libido was roughly the same in the three Viagra groups. In other words, the means for partner’s libido are not significantly different in the placebo, low- and high-dose groups. This result means that it is appropriate to use partner’s libido as a covariate in the analysis.


## 4. Do the ANCOVA
If we want Type I sums of squares, then we enter covariate(s) first, and the independent variable(s) second.

### A wrong way, without setting *contrasts*

{% highlight r %}
# get type I sums of squares
viagraModel.2<-aov(libido ~ partnerLibido + dose, data = viagraData)
# get Type II or III sums of squares
Anova(viagraModel.2, type = "III")  # from car package
{% endhighlight %}



{% highlight text %}
## Anova Table (Type III tests)
## 
## Response: libido
##               Sum Sq Df F value Pr(>F)  
## (Intercept)     12.9  1    4.26  0.049 *
## partnerLibido   15.1  1    4.96  0.035 *
## dose            25.2  2    4.14  0.027 *
## Residuals       79.0 26                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}

### A correct way, with setting orthogonal *contrasts*
To calculate Type III sums of squares properly we *must* specify orthogonal contrasts.

{% highlight r %}
contrasts(viagraData$dose)<-cbind(c(-2,1,1), c(0,-1,1))
viagraModel<-aov(libido ~ partnerLibido + dose, data = viagraData)
Anova(viagraModel, type="III")
{% endhighlight %}



{% highlight text %}
## Anova Table (Type III tests)
## 
## Response: libido
##               Sum Sq Df F value  Pr(>F)    
## (Intercept)     76.1  1   25.02 3.3e-05 ***
## partnerLibido   15.1  1    4.96   0.035 *  
## dose            25.2  2    4.14   0.027 *  
## Residuals       79.0 26                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}
From the output, we can find that the p-value of *Intercept* after setting orthogonal contrasts becomes much smaller. 

### Adjusted means
Based on the output in self-test 1, we can see the low- and high-dose groups have very similar means, 4.88 and 4.85, whereas the placebo group mean is much lower at 3.22. Actually we can’t interpret these group means because they have not been adjusted for the effect of the covariate. 

To get the *adjusted means* we need to use the `effect()` function in the *effects* package.


{% highlight r %}
library(effects)
# se=TRUE: show standard errors
adjustedMeans<-effect("dose", viagraModel, se=TRUE)
summary(adjustedMeans)
{% endhighlight %}



{% highlight text %}
## 
##  dose effect
## dose
##   Placebo  Low Dose High Dose 
##       2.9       4.7       5.2 
## 
##  Lower 95 Percent Confidence Limits
## dose
##   Placebo  Low Dose High Dose 
##       1.7       3.4       4.1 
## 
##  Upper 95 Percent Confidence Limits
## dose
##   Placebo  Low Dose High Dose 
##       4.2       6.0       6.2
{% endhighlight %}



{% highlight r %}
adjustedMeans$se
{% endhighlight %}



{% highlight text %}
## [1] 0.60 0.62 0.50
{% endhighlight %}
The output shows the adjusted means (and their confidence intervals) and also the standard errors. Unlike the means in self-test 1, these adjusted means for the low-dose and high-dose groups are fairly different. In other words, when the means are adjusted for the effect of the covariate it looks very much like as dose increases, libido increases (from 2.93 in the placebo group, to 4.71 in the low-dose group and 5.15 in the high-dose group).

### Self-test 4
Run a one-way ANOVA to see whether the three groups differ in their levels of libido.

{% highlight r %}
anovaModel<-aov(libido ~ dose, data = viagraData)
summary(anovaModel)
{% endhighlight %}



{% highlight text %}
##             Df Sum Sq Mean Sq F value Pr(>F)
## dose         2   16.8    8.42    2.42   0.11
## Residuals   27   94.1    3.49
{% endhighlight %}
This output shows (for illustrative purposes) the ANOVA table for these data *when the covariate is not included*. It is clear from the significance value, which is greater than .05, that Viagra seems to have no significant effect on libido. Therefore, without taking account of the libido of the participants’ partners we would have concluded that Viagra had no significant effect on libido, yet it does.


## 5. Compute contrasts or post hoc tests

### Interpret planned contrasts
The overall ANCOVA does not tell us which means differ, so to break down the overall effect of *dose* we need to look at the contrasts that we specified before we created the ANCOVA model.


{% highlight r %}
summary.lm(viagraModel)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## aov(formula = libido ~ partnerLibido + dose, data = viagraData)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -3.262 -0.790 -0.323  0.881  4.570 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)      3.126      0.625    5.00  3.3e-05 ***
## partnerLibido    0.416      0.187    2.23   0.0348 *  
## dose1            0.668      0.240    2.79   0.0099 ** 
## dose2            0.220      0.406    0.54   0.5928    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 1.7 on 26 degrees of freedom
## Multiple R-squared:  0.288,	Adjusted R-squared:  0.205 
## F-statistic:  3.5 on 3 and 26 DF,  p-value: 0.0295
{% endhighlight %}
The first dummy variable (**dose1**) compares the placebo group with the low- and high-dose groups. The associated t-statistic is significant, indicating that the placebo group was significantly different from the combined mean of the Viagra groups.

The second dummy variable (**dose2**) compares the low- and high-dose groups. The associated t-statistic is not significant, indicating that the high-dose group did not produce a significantly higher libido than the low-dose group.

### *Post hoc* tests
Because we want to test differences between the *adjusted* means, we can use only the `glht()` function; the `pairwise.t.test()` function will not test the adjusted means. As such, we are limited to using Tukey or Dunnett’s post hoc tests.

{% highlight r %}
library(multcomp)
postHocs<-glht(viagraModel, linfct = mcp(dose = "Tukey"))
summary(postHocs)
{% endhighlight %}



{% highlight text %}
## 
## 	 Simultaneous Tests for General Linear Hypotheses
## 
## Multiple Comparisons of Means: Tukey Contrasts
## 
## 
## Fit: aov(formula = libido ~ partnerLibido + dose, data = viagraData)
## 
## Linear Hypotheses:
##                           Estimate Std. Error t value Pr(>|t|)  
## Low Dose - Placebo == 0      1.786      0.849    2.10    0.109  
## High Dose - Placebo == 0     2.225      0.803    2.77    0.026 *
## High Dose - Low Dose == 0    0.439      0.811    0.54    0.852  
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
## Fit: aov(formula = libido ~ partnerLibido + dose, data = viagraData)
## 
## Quantile = 2.5
## 95% family-wise confidence level
##  
## 
## Linear Hypotheses:
##                           Estimate lwr    upr   
## Low Dose - Placebo == 0    1.786   -0.325  3.896
## High Dose - Placebo == 0   2.225    0.230  4.220
## High Dose - Low Dose == 0  0.439   -1.576  2.455
{% endhighlight %}
This output suggests significant differences between the high-dose and placebo groups (t = 2.77, p < .05). The confidence intervals also confirm this conclusion because they do not cross zero for the comparison of the high dose and placebo groups.

### Plots
aov() function automatically generates some plots that we can use to test the assumptions. We can see these graphs by executing:

{% highlight r %}
plot(viagraModel)
{% endhighlight %}

<img src="/assets/Rfig/ANCOVA-notes-residual_by_plot-1.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/ANCOVA-notes-residual_by_plot-2.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/ANCOVA-notes-residual_by_plot-3.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/ANCOVA-notes-residual_by_plot-4.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" />
You will actually see four graphs, but the first two are the most important. The first graph (on the left of the figure) can be used for testing homogeneity of variance. The plot we have does show funnelling (the spread of scores is wider at some points than at others), which implies that the residuals might be heteroscedastic (a bad thing). The second plot (on the right) is a Q-Q plot, which tells us about the normality of residuals in the model. 
> It looks like the diagonal line has not washed for several weeks and the dots are running away from the smell. 

Again, this is not good news for the model. These plots suggest that a robust version of ANCOVA might be in order.


## 6. Check for homogeneity of regression slopes
### Self-test 5
Use *ggplot2* to re-create Figure 11.3.

{% highlight r %}
scatter <- ggplot(viagraData, aes(partnerLibido, libido, colour = dose))
scatter + geom_point(aes(shape = dose), size = 3) + 
    geom_smooth(method = "lm", aes(fill = dose), alpha = 0.1) +
    labs(x = "Partner's Libido", y = "Participant's Libido")
{% endhighlight %}

![plot of chunk self_test_5](/assets/Rfig/ANCOVA-notes-self_test_5-1.svg)
The output shows the scatterplots of the relationship between **partnerLibido** and **libido** in the three groups. This scatterplot showed that although this relationship was comparable in the low-dose and placebo groups, it appeared different in the high-dose group.

### Use Anova() to test homogeneity of regression slopes
To test the assumption of homogeneity of regression slopes we need to run the ANCOVA again, but include the interaction between the covariate and predictor variable.


{% highlight r %}
# three different ways, giving the same result
# hoRS<-aov(libido ~ partnerLibido + dose + dose:partnerLibido, data = viagraData)
# hoRS<-aov(libido ~ partnerLibido*dose, data = viagraData)
hoRS<-update(viagraModel, .~. + partnerLibido:dose)
Anova(hoRS, type="III")  # from car package
{% endhighlight %}



{% highlight text %}
## Anova Table (Type III tests)
## 
## Response: libido
##                    Sum Sq Df F value  Pr(>F)    
## (Intercept)          53.5  1   21.92 9.3e-05 ***
## partnerLibido        17.2  1    7.03   0.014 *  
## dose                 36.6  2    7.48   0.003 ** 
## partnerLibido:dose   20.4  2    4.18   0.028 *  
## Residuals            58.6 24                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}
The main thing in which we’re interested is the interaction term, so look at the significance value of the covariate by outcome interaction (**partnerLibido:dose**), if this effect is significant then the assumption of homogeneity of regression slopes has been broken.

## Robust test (skipped)
Based on the previous output, a robust version of ANCOVA might be in order. However, since the book uses a different dataset, I'd like to skip this part.

## Effect size
There are several ways to calculate effect sizes.
* Eta squared ($\eta^2$), see chapter 10. This effect size is just $r^2$ by another name and is calculated by dividing the effect of interest, $SS_M$, by the total amount of variance in the data, $SS_T$. As such, it is the proportion of total variance explained by an effect. Since we have more than one effect, we could calculate $\eta^2$ for each effect.
* Partial eta squared (*partial* $\eta^2$), see section 11.6. This differs from eta squared in that it looks not at the proportion of total variance that a variable explains, but at the proportion of variance that a variable explains that is not explained by other variables in the analysis.
* Omega squared ($\omega^2$), see section 10.7. This measure computes the overall effect size. It can be calculated only when we have equal numbers of participants in each group. If it's not the case, then use `rcontrast()` below.
* `rcontrast(t, df)`, see section 10.7 and 11.6.
This measure computes the effect size for more focused comparisons like planned contrasts.

{% highlight r %}
rcontrast<-function(t, df)
{
  r<-sqrt(t^2/(t^2 + df))
  print(paste("r = ", r))
}
{% endhighlight %}
Therefore, based on the output from [Interpret planned contrasts](#interpret-planned-contrasts) in Step 5, the t-value of each effect is 2.23, 2.79, and 0.54. The degree of freedom is 26.

{% highlight r %}
t<-c(2.23, 2.79, 0.54)
df<-26
rcontrast(t, df)
{% endhighlight %}



{% highlight text %}
## [1] "r =  0.400695004307376" "r =  0.480007503471119"
## [3] "r =  0.105313792270809"
{% endhighlight %}
The output shows that the effect of the covariate (.400) and the difference between the combined dose groups and the placebo (.479) both represent medium to large effect sizes (they’re both between .4 and .5). The difference between the high- and low-dose groups (.106) was a fairly small effect.
* `mes()`, see section 11.6. This method calculates effect sizes between all combinations of groups. I'd like to skip this method.

## Conclusion
I only keep the R code and some very brief interpretation of the results. To see the rationale of each method or read more description of each method, it is a good idea to read the book sections. For convenience, I have added section numbers for some methods.

Thanks for reading and feel free to correct me if I made any mistake. 

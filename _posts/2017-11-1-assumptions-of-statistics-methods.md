---
layout: post
title: "Assumptions of Statistics Analysis"
author: "Gaoping Huang"
use_math: true
use_bootstrap: true
---



A brief summary of the assumptions of statistic methods from the book "Discovering Statistics using R (2012)" by Andy Field. Most text is directly copied from the book chapter. All the credit goes to him.

To test these assumptions using R, click "Toggle Code" button.

## Parametric data
See section 5.3
### 1. Normally distributed data
It means different things in different contexts. See more details in each analysis.

Shapiro-Wilk test, see section 5.6.
{% include toggle_button.html target="collapseShapiroTest" %}
<div markdown="1" class="collapse" id="collapseShapiroTest">

{% highlight r %}
rexam <- read.delim("../assets/Rdata/RExam.dat", header=TRUE)
shapiro.test(rexam$exam)
{% endhighlight %}



{% highlight text %}
## 
## 	Shapiro-Wilk normality test
## 
## data:  rexam$exam
## W = 0.96131, p-value = 0.004991
{% endhighlight %}
Since p < 0.05, the distribution is not normal.

Now if we’d asked for separate Shapiro–Wilk tests for the two universities, we might have found non-significant results:

{% highlight r %}
rexam$uni<-factor(rexam$uni, levels = c(0:1), labels = c("Duncetown University", "Sussex University"))
by(rexam$exam, rexam$uni, shapiro.test)
{% endhighlight %}



{% highlight text %}
## rexam$uni: Duncetown University
## 
## 	Shapiro-Wilk normality test
## 
## data:  dd[x, ]
## W = 0.97217, p-value = 0.2829
## 
## -------------------------------------------------------- 
## rexam$uni: Sussex University
## 
## 	Shapiro-Wilk normality test
## 
## data:  dd[x, ]
## W = 0.98371, p-value = 0.7151
{% endhighlight %}
</div>

### 2. Homogeneity of variance
This assumption means that the variances should be the same throughout the data. If you’ve collected groups of data then this means that the variance of your outcome variable or variables should be the same in each of these groups. If you’ve collected continuous data (such as in correlational designs), this assumption means that the variance of one variable should be stable at all levels of the other variable. 

Levene's test, see section 5.7.
{% include toggle_button.html target="collapseLeveneTest" %}
<div markdown="1" class="collapse" id="collapseLeveneTest">

{% highlight r %}
library(car)
leveneTest(rexam$exam, rexam$uni, center=median)  # center could be mean
{% endhighlight %}



{% highlight text %}
## Levene's Test for Homogeneity of Variance (center = median)
##       Df F value Pr(>F)
## group  1  2.0886 0.1516
##       98
{% endhighlight %}
This indicates that the variances are not significantly different (i.e., they are similar and the homogeneity of variance assumption is tenable).
</div>


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

The VIF and tolerance statistics (with tolerance being 1 divided by the VIF) are useful statistics to assess collinearity, see section 7.9.4.

{% include toggle_button.html target="collapseVIFTest" %}
<div markdown="1" class="collapse" id="collapseVIFTest">

{% highlight r %}
album2 <- read.delim("../assets/Rdata/Album Sales 2.dat", header = TRUE)
albumSales.3 <- lm(sales ~ adverts + airplay + attract, data = album2)
vif(albumSales.3)
{% endhighlight %}



{% highlight text %}
##  adverts  airplay  attract 
## 1.014593 1.042504 1.038455
{% endhighlight %}



{% highlight r %}
1/vif(albumSales.3)  # tolerance
{% endhighlight %}



{% highlight text %}
##   adverts   airplay   attract 
## 0.9856172 0.9592287 0.9629695
{% endhighlight %}



{% highlight r %}
mean(vif(albumSales.3))
{% endhighlight %}



{% highlight text %}
## [1] 1.03185
{% endhighlight %}
* If the largest VIF is greater than 10 then there is cause for concern (Bowerman & O’Connell, 1990; Myers, 1990).
* If the average VIF is substantially greater than 1 then the regression may be biased (Bowerman & O’Connell, 1990).
* Tolerance below 0.1 indicates a serious problem.
* Tolerance below 0.2 indicates a potential problem (Menard, 1995).

For our current model the VIF values are all well below 10 and the tolerance statistics all well above 0.2. Also, the average VIF is very close to 1. Based on these measures we can safely conclude that there is no collinearity within our data.
</div>

### 4. Predictors are uncorrelated with ‘external variables’
External variables are variables that haven’t been included in the regression model which influence the outcome variable.

### 5. Homoscedasticity
At each level of the predictor variable(s), the variance of the residual terms should be constant. This just means that the residuals at each level of the predictor(s) should have the same variance.

### 6. Independent errors
For any two observations the residual terms should be uncorrelated (or independent). 

Durbin–Watson test, see section 7.9.3.
{% include toggle_button.html target="collapseDurbinWatsonTest" %}
<div markdown="1" class="collapse" id="collapseDurbinWatsonTest">

{% highlight r %}
# albumSales.3 is calculated above
durbinWatsonTest(albumSales.3)
{% endhighlight %}



{% highlight text %}
##  lag Autocorrelation D-W Statistic p-value
##    1       0.0026951      1.949819   0.738
##  Alternative hypothesis: rho != 0
{% endhighlight %}
> As a conservative rule I suggested that values less than 1 or greater than 3 should definitely raise alarm bells. The closer to 2 that the value is, the better, and for these data (Output 7.8) the value is 1.950, which is so close to 2 that the assumption has almost certainly been met. The p-value of .7 confirms this conclusion (it is very much bigger than .05 and, therefore, not remotely significant).

</div>

### 7. Normally distributed errors
It is assumed that the residuals in the model are random, normally distributed variables with a mean of 0.

If we wanted to produce high-quality graphs for publication we would use *ggplot2()*. However, if we’re just looking at these graphs to check our assumptions, we’ll use the simpler (but not as nice) `plot()` and `hist()` functions.

{% include toggle_button.html target="collapseResidualTest" %}
<div markdown="1" class="collapse" id="collapseResidualTest">

{% highlight r %}
plot(albumSales.3)
{% endhighlight %}

<img src="/assets/Rfig/assumption-of-statistics-residual_by_plot-1.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/assumption-of-statistics-residual_by_plot-2.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/assumption-of-statistics-residual_by_plot-3.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" /><img src="/assets/Rfig/assumption-of-statistics-residual_by_plot-4.svg" title="plot of chunk residual_by_plot" alt="plot of chunk residual_by_plot" width="50%" style="float:left" />
<div style="clear: both;"></div>

{% highlight r %}
hist(rstudent(albumSales.3))
{% endhighlight %}

<img src="/assets/Rfig/assumption-of-statistics-residual_by_hist-1.svg" title="plot of chunk residual_by_hist" alt="plot of chunk residual_by_hist" style="display: block; margin: auto;" />
</div>

### 8. Independence
It is assumed that all of the values of the outcome variable are independent (in other words, each value of the outcome variable comes from a separate entity).

### 9. Linearity
The mean values of the outcome variable for each increment of the predictor(s) lie along a straight line.


## Logistic Regression
See section 8.4. Logistic regression shares some of the assumptions of normal regression: 1) Linearity, 2) Independent errors, and 3) Multicollinearity.

## Comparing two means, t-test
Both independent t-test and the dependent t-test are *parametric tests* mentioned above. See section 9.4.3.
1. The sampling distribution is normally distributed.
In the dependent t-test this means that the sampling distribution of the *differences* between scores should be normal, not the scores themselves (see section 9.6.3.4).
2. Data are measured at least at the interval level.

The independent t-test, because it is used to test different groups of people, also assumes:
1. Independence. 
Scores in different treatment conditions are independent (because they come from different people).
2. Homogeneity of variance.
Well, at least in theory we assume equal variances, but in reality we don’t (Jane Superbrain Box 9.2).

## ANOVA
The assumptions of *parametric test* also apply here.
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

We can run an ANOVA to test whether the covariate variable and treatment variable are independent or not. See section 11.4.6.

{% include toggle_button.html target="collapseANCOVATest1" %}
<div markdown="1" class="collapse" id="collapseANCOVATest1">

{% highlight r %}
viagraData <- read.delim("../assets/Rdata/ViagraCovariate.dat", header = TRUE)
viagraData$dose <- factor(viagraData$dose, levels = c(1:3),
    labels = c("Placebo", "Low Dose", "High Dose"))
viagraModel <- aov(partnerLibido ~ dose, data=viagraData)
summary(viagraModel)
{% endhighlight %}



{% highlight text %}
##             Df Sum Sq Mean Sq F value Pr(>F)
## dose         2  12.77   6.385   1.979  0.158
## Residuals   27  87.10   3.226
{% endhighlight %}
The means for partner’s libido are not significantly different in the placebo, low- and high-dose groups. This result means that it is appropriate to use partner’s libido as a covariate in the analysis.
</div>


### 2. Homogeneity of regression slopes
For example, if there’s a positive relationship between the covariate and the outcome in one group, we assume that there is a positive relationship in all of the other groups too.

If you have violated the assumption of homogeneity of regression slopes, or if the variability in regression slopes is an interesting hypothesis in itself, then you can explicitly model this variation using multilevel linear models (see Chapter 19).

To test the assumption of homogeneity of regression slopes we need to run the ANCOVA again, but include the interaction between the covariate and predictor variable. See section 11.4.14.

{% include toggle_button.html target="collapseANCOVATest2" %}
<div markdown="1" class="collapse" id="collapseANCOVATest2">

{% highlight r %}
hoRS <- aov(libido ~ partnerLibido*dose, data = viagraData)
Anova(hoRS, type="III")  # from car package
{% endhighlight %}



{% highlight text %}
## Anova Table (Type III tests)
## 
## Response: libido
##                    Sum Sq Df F value   Pr(>F)   
## (Intercept)         0.771  1  0.3157 0.579405   
## partnerLibido      19.922  1  8.1565 0.008715 **
## dose               36.558  2  7.4836 0.002980 **
## partnerLibido:dose 20.427  2  4.1815 0.027667 * 
## Residuals          58.621 24                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
{% endhighlight %}
The main thing in which we’re interested is the interaction term, so look at the significance value of the covariate by outcome interaction ( **partnerLibido:dose** ), if this effect is significant then the assumption of homogeneity of regression slopes has been broken.
</div>


## Repeated-measures design

### 1. Sphericity
The assumption of sphericity can be likened to the assumption of homogeneity of variance in *between-group* ANOVA. See section 13.2.1.

Sphericity refers to the equality of variances of the *differences* between treatment levels. So, if you were to take each pair of treatment levels, and calculate the differences between each pair of scores, then it is necessary that these differences have approximately equal variances. As such, *you need at least three conditions for sphericity to be an issue.*

$$Variance_{A–B} ≈ Variance_{A–C} ≈ Variance_{B–C}$$

Mauchly’s test, see section 13.4.7.1.
{% include toggle_button.html target="collapseMauchlyTest" %}
<div markdown="1" class="collapse" id="collapseMauchlyTest">

{% highlight r %}
Participant<-gl(8, 4, labels = c("P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8" ))
Animal<-gl(4, 1, 32, labels = c("Stick Insect", "Kangaroo Testicle", "Fish Eye", "Witchetty Grub"))
Retch<-c(8, 7, 1, 6, 9, 5, 2, 5, 6, 2, 3, 8, 5, 3, 1, 9, 8, 4, 5, 8, 7, 5, 6, 7, 10, 2, 7, 2, 12, 6, 8, 1)
longBush<-data.frame(Participant, Animal, Retch)

library(ez)
bushModel<-ezANOVA(data = longBush, dv = .(Retch), wid = .(Participant), within = .(Animal), detailed = TRUE, type = 3)
bushModel
{% endhighlight %}



{% highlight text %}
## $ANOVA
##        Effect DFn DFd     SSn     SSd          F            p p<.05
## 1 (Intercept)   1   7 990.125  17.375 398.899281 1.973536e-07     *
## 2      Animal   3  21  83.125 153.375   3.793806 2.557030e-02     *
##         ges
## 1 0.8529127
## 2 0.3274249
## 
## $`Mauchly's Test for Sphericity`
##   Effect        W          p p<.05
## 2 Animal 0.136248 0.04684581     *
## 
## $`Sphericity Corrections`
##   Effect       GGe      p[GG] p[GG]<.05       HFe      p[HF] p[HF]<.05
## 2 Animal 0.5328456 0.06258412           0.6657636 0.04833061         *
{% endhighlight %}
The important column is the one containing the significance value (p) and in this case the value, .047, is less than the critical value of .05 (which is why there is an asterisk next to the p-value), so we reject the assumption that the variances of the differences between levels are equal. In other words, the assumption of sphericity has been violated, W = 0.14, p = .047. 
</div>

## Categorical data, chi-square test, loglinear analysis

### 1. Independence of data
For the chi-square test to be meaningful it is imperative that each person, item or entity contributes to only one cell of the contingency table. Therefore, you cannot use a chi-square test on a repeated-measures design.

### 2. The expected frequencies should be greater than 5.
Although it is acceptable in larger contingency tables to have up to 20% of expected frequencies below 5, the result is a loss of statistical power.

Use `CrossTable()` from *gmodels* package, see section 18.6.4.

{% include toggle_button.html target="collapseCrossTable" %}
<div markdown="1" class="collapse" id="collapseCrossTable">

{% highlight r %}
catsData<-read.delim("../assets/Rdata/cats.dat", header = TRUE)

library(gmodels)
CrossTable(catsData$Training, catsData$Dance, fisher = TRUE, chisq = TRUE, 
  expected = TRUE, prop.c = FALSE, prop.t = FALSE, 
  prop.chisq = FALSE,  sresid = TRUE, format = "SPSS")
{% endhighlight %}



{% highlight text %}
## 
##    Cell Contents
## |-------------------------|
## |                   Count |
## |         Expected Values |
## |             Row Percent |
## |            Std Residual |
## |-------------------------|
## 
## Total Observations in Table:  200 
## 
##                     | catsData$Dance 
##   catsData$Training |       No  |      Yes  | Row Total | 
## --------------------|-----------|-----------|-----------|
## Affection as Reward |      114  |       48  |      162  | 
##                     |  100.440  |   61.560  |           | 
##                     |   70.370% |   29.630% |   81.000% | 
##                     |    1.353  |   -1.728  |           | 
## --------------------|-----------|-----------|-----------|
##      Food as Reward |       10  |       28  |       38  | 
##                     |   23.560  |   14.440  |           | 
##                     |   26.316% |   73.684% |   19.000% | 
##                     |   -2.794  |    3.568  |           | 
## --------------------|-----------|-----------|-----------|
##        Column Total |      124  |       76  |      200  | 
## --------------------|-----------|-----------|-----------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  25.35569     d.f. =  1     p =  4.767434e-07 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  23.52028     d.f. =  1     p =  1.236041e-06 
## 
##  
## Fisher's Exact Test for Count Data
## ------------------------------------------------------------
## Sample estimate odds ratio:  6.579265 
## 
## Alternative hypothesis: true odds ratio is not equal to 1
## p =  1.311709e-06 
## 95% confidence interval:  2.837773 16.42969 
## 
## Alternative hypothesis: true odds ratio is less than 1
## p =  0.9999999 
## 95% confidence interval:  0 14.25436 
## 
## Alternative hypothesis: true odds ratio is greater than 1
## p =  7.7122e-07 
## 95% confidence interval:  3.193221 Inf 
## 
## 
##  
##        Minimum expected frequency: 14.44
{% endhighlight %}
or use a different form below, which gives the same result:

{% highlight r %}
CrossTable(contingencyTable, fisher = TRUE, chisq = TRUE, 
  expected = TRUE, prop.c = FALSE, prop.t = FALSE, 
  prop.chisq = FALSE,  sresid = TRUE, format = "SPSS")
{% endhighlight %}
The second row of each cell shows the expected frequencies; it should be clear that the smallest expected count is 14.44 (for cats that were trained with food and did dance). This value exceeds 5 and so the assumption has been met.
</div>

## Conclusion
Again, this post is only a brief summary of the assumptions mentioned in the book. Most text is directly copied from the book chapter. All the credit goes to Andy Field.


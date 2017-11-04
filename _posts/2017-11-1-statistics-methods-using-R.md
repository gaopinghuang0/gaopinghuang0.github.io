---
layout: post
title: "Summary of Statistics Methods using R"
author: "Gaoping Huang"
use_math: true
---


A brief summary of common statistic methods using R from the book "Discovering Statistics using R" by Andy Field.


## Useful packages
* *boot* - for bootstrap
    * `boot()`, see section 6.5.7, such as `boot_kendall<-boot(liarData, bootTau, 2000)`
    * `boot.ci()`, confidence interval, such as `boot.ci(boot_kendall, conf=0.99)`, see section 6.5.7
* *car* - for Levene's test, Type III sums of squares
    * `leveneTest()`, such as `leveneTest(viagraData$libido, viagraData$dose, center = median)`
    * `Anova()`, such as `Anova(modelName, type="III")`, see section 11.4.7
* *compute.es* - for effect sizes
    * `mes()`, see section 11.6, calculate effect sizes between all combinations of groups
* *effects* - for adjusted means
    * `effect()`, see section 11.4.8
* *ez* - for *ANOVA*
* *ggplot2* - for graphs
* *ggm* - for partial correlation
    * `pcor()`, partial correlation, see section 6.6.2
    * `pcor.test()`, significance of partial correlation, see section 6.6.2
* *Hmisc* - for correlation
    * `rcorr()`, for correlation, see section 6.5.3
* *multcomp* - for *post hoc* tests
* *pastecs* - for descriptive statistics
    * `stat.desc()`, such as `by(viagraData$libido, viagraData$dose, stat.desc)`
* *polycor* - for correlation
    * `polyserial()`, biserial correlation, see section 6.5.8
* *psych* -
    * `describe()` - such as `describe(dlf$day1)`, similar to `stat.desc()` above.
* *stats* - built-in, auto-loaded
    * `wilcox.test()`
    * `shapiro.test()`, Shapiro-Wilk test, such as `shapiro.test(variable)`
    * `cor()`, for correlation
    * `cor.test()`, for correlation
* *WRS* - for robust tests, see section 5.8.4
  * Updated website: [http://dornsife.usc.edu/labs/rwilcox/software/]
  * `source("http://dornsife.usc.edu/assets/sites/239/docs/Rallfun-v34.txt")`  -- new website
  * `ancova()` and `ancboot()`, see section 11.5


## Check assumptions
See more description about assumptions at [Assumptions of Statistics Analysis](/2017/11/01/assumptions-of-statistics-methods).

### 1. Normality
Shapiro-Wilk test

{% highlight r %}
setwd("../assets/Rdata")
rexam <- read.delim("RExam.dat", header=TRUE)
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

### 2. Homogeneity of variance
Levene's test

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

### Dealing with non-normality and unequal variances
Transforming data, such as log transformation, square root transformation, see section 5.8.2.


## Effect size

* Eta squared ($\eta^2$), see chapter 10

* Partial eta squared (*partial* $\eta^2$), see section 11.6

* Omega squared ($\omega^2$), see section 10.7.
This measure computes the overall effect size. It can be calculated only when we have equal numbers of participants in each group. If it's not the case, then use `rcontrast()` below.

* `rcontrast(t, df)`, see section 10.7 and 11.6.
This measure computes the effect size for more focused comparisons like planned contrasts.

{% highlight r %}
rcontrast<-function(t, df)
{
  r<-sqrt(t^2/(t^2 + df))
  print(paste("r = ", r))
}
{% endhighlight %}

* `mes()`, see section 11.6.
This method calculates effect sizes between all combinations of groups

---
layout: post
title: "Summary of Statistics Methods using R"
author: "Gaoping Huang"
use_math: true
use_bootstrap: false
---


A brief summary of common statistic methods using R from the book "Discovering Statistics using R (2012)" by Andy Field.


## Useful packages
* *boot* - for bootstrap
    * `boot()`, see section 6.5.7, such as `boot_kendall<-boot(liarData, bootTau, 2000)`
    * `boot.ci()`, confidence interval, such as `boot.ci(boot_kendall, conf=0.99)`, see section 6.5.7
* *car* - for Levene's test, Type III sums of squares, and more
    * `leveneTest()`, such as `leveneTest(viagraData$libido, viagraData$dose, center = median)`
    * `Anova()`, such as `Anova(modelName, type="III")`, see section 11.4.7
    * `durbinWatsonTest()` or `dwt()`, Durbin–Watson test for assumption of independent errors, see section 7.9.3
* *compute.es* - for effect sizes
    * `mes()`, see section 11.6, calculate effect sizes between all combinations of groups
* *effects* - for adjusted means
    * `effect()`, see section 11.4.8
* *ez* - for *ANOVA*
    * `ezANOVA()`, repeated-measures ANOVA, see section 12.4.7
* *ggplot2* - for graphs
* *ggm* - for partial correlation
    * `pcor()`, partial correlation, see section 6.6.2
    * `pcor.test()`, significance of partial correlation, see section 6.6.2
* *gmodels* - for chi-square
    * `CrossTable()`, see section 18.6.4.
* *Hmisc* - for correlation
    * `rcorr()`, for correlation, see section 6.5.3
* *MASS* - for loglinear analysis
* *mlogit* - for multinomial logistic regression
* *multcomp* - for *post hoc* tests
    * `glht()`, see section 11.4.11.
* *pastecs* - for descriptive statistics
    * `stat.desc()`, such as `by(viagraData$libido, viagraData$dose, stat.desc)`
* *polycor* - for correlation
    * `polyserial()`, biserial correlation, see section 6.5.8
* *psych* -
    * `describe()` - such as `describe(dlf$day1)`, similar to `stat.desc()` above.
* *QuantPsyc* - to get standardized regression coefficients
* *stats* - built-in, auto-loaded
    * `wilcox.test()`
    * `shapiro.test()`, Shapiro-Wilk test, such as `shapiro.test(variable)`
    * `cor()`, for correlation
    * `cor.test()`, for correlation
    * `anova()`, compare models, see section 7.8.4.2; which is different from `Anova()` from *car* package
    * `confint()`, computes confidence interval
* *WRS* - for robust tests, see section 5.8.4
  * Updated website: <http://dornsife.usc.edu/labs/rwilcox/software/>
  * `source("http://dornsife.usc.edu/assets/sites/239/docs/Rallfun-v34.txt")`  -- new website
  * `ancova()` and `ancboot()`, see section 11.5



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


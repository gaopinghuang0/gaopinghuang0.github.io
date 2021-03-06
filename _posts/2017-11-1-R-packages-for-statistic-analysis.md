---
layout: post
title: "Useful R Packages for Statistic Analysis"
author: "Gaoping Huang"
tags: R
use_math: true
use_bootstrap: false
---


A brief summary of R packages (and corresponding functions) that are used in the book "Discovering Statistics using R (2012)" by Andy Field.

Packages and functions (order by alphabetical):
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
    * `glht()`, Tukey tests, see section 11.4.11.
* *pastecs* - for descriptive statistics
    * `stat.desc()`, such as `by(viagraData$libido, viagraData$dose, stat.desc)`
* *polycor* - for correlation
    * `polyserial()`, biserial correlation, see section 6.5.8
* *psych* -
    * `describe()` - such as `describe(dlf$day1)`, similar to `stat.desc()` above.
* *QuantPsyc* - to get standardized regression coefficients
* *reshape2* - for reshape
    * `melt()`
* *stats* - built-in, auto-loaded
    * `wilcox.test()`
    * `shapiro.test()`, Shapiro-Wilk test, such as `shapiro.test(variable)`
    * `cor()`, for correlation
    * `cor.test()`, for correlation
    * `anova()`, compare models, see section 7.8.4.2; which is different from `Anova()` from *car* package
    * `confint()`, computes confidence interval
* *WRS* - for robust tests, see section 5.8.4
  * Updated website: <http://dornsife.usc.edu/labs/rwilcox/software/>
  * `source("http://dornsife.usc.edu/assets/sites/239/docs/Rallfun-v34.txt")`  -- new website. Since all functions become available in R environment, there is no need to call `library(WRS)`.
  * `ancova()` and `ancboot()`, see section 11.5





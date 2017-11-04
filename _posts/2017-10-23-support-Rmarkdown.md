---
layout: post
title: "Supporting R Markdown with Jekyll, knitr, and MathJax"
author: "Gaoping"
---

Blogging with Jekyll and Markdown is good. Blogging with Jekyll and R Markdown is even better.

Based on the following two posts, I figured out how to support R Markdown using knitr. The basic idea is to use knitr to convert R Markdown files to Jekyll friendly markdown files.

1. [Blogging with Jekyll and R Markdown using knitr](http://brooksandrew.github.io/simpleblog/articles/blogging-with-r-markdown-and-jekyll-using-knitr/) by Andrew
2. [Publishing R Markdown using Jekyll](https://chepec.se/2014/07/16/knitr-jekyll) by chepec

The first blog is adapted from the second blog, so their basic idea is the same. Based on their idea, I made some minor changes - all the credit goes to them.

Also, I added some extra features such as auto-rerun bash script whenever we make changes to an R Markdown file, even on Windows.

## Use R script to call knitr
Here are the steps:

1. Create a directory called `_Rmd` at the root level of the Jekyll directory, which will store all R Markdown files. In `_Rmd`, an R script is also created (called `render_post.R`), which is adapted from the first blog and shown below.
2. Configure the paths for each directory accordingly, for example, `posts.path` is `_posts`.
3. Create an R Markdown post under `_Rmd`, such as `2017-10-23-test-markdown.Rmd`. At the beginning of this file, remember to add proper front matter for Jekyll.
4. Run `KnitPost` to convert files. For simplicity, in the next section, I created a bash script to convert `_Rmd/*.Rmd` to `_post/*.md`.

```R
# render_post.R
# R script to convert RMarkdown into Jekyll markdown
# Credit: http://brooksandrew.github.io/simpleblog/articles/blogging-with-r-markdown-and-jekyll-using-knitr/

KnitPost <- function(site.path='/pathToYourBlog/', overwriteAll=F, overwriteOne=NULL) {
  if(!'package:knitr' %in% search()) suppressWarnings(library(knitr))

  ## Blog-specific directories.  This will depend on how you organize your blog.
  site.path <- site.path # directory of jekyll blog (including trailing slash)
  rmd.path <- paste0(site.path, "_Rmd") # directory where your Rmd-files reside (relative to base)
  fig.dir <- "assets/Rfig/" # directory to save figures
  posts.path <- paste0(site.path, "_posts") # directory for converted markdown files
  cache.path <- paste0(site.path, "_cache") # necessary for plots
  
  render_jekyll(highlight = "pygments")
  opts_knit$set(base.url = '/', base.dir = site.path)
  opts_chunk$set(fig.path=fig.dir, fig.width=8.5, fig.height=5.25, dev='svg', cache=F, 
                 warning=F, message=F, cache.path=cache.path, tidy=F)   
  
  # setwd(rmd.path) # setwd to base
  
  # some logic to help us avoid overwriting already existing md files
  files.rmd <- data.frame(rmd = list.files(path = rmd.path,
                                full.names = T,
                                pattern = "\\.Rmd$",
                                ignore.case = T,
                                recursive = F), stringsAsFactors=F)
  files.rmd$corresponding.md.file <- paste0(posts.path, "/", basename(gsub(pattern = "\\.Rmd$", replacement = ".md", x = files.rmd$rmd)))
  files.rmd$corresponding.md.exists <- file.exists(files.rmd$corresponding.md.file)
  
  ## determining which posts to overwrite from parameters overwriteOne & overwriteAll
  files.rmd$md.overwriteAll <- overwriteAll
  if(is.null(overwriteOne)==F) files.rmd$md.overwriteAll[grep(overwriteOne, files.rmd[,'rmd'], ignore.case=T)] <- T
  files.rmd$md.render <- F
  for (i in 1:dim(files.rmd)[1]) {
    if (files.rmd$corresponding.md.exists[i] == F) {
      files.rmd$md.render[i] <- T
    }
    if ((files.rmd$corresponding.md.exists[i] == T) && (files.rmd$md.overwriteAll[i] == T)) {
      files.rmd$md.render[i] <- T
    }
  }
  
  # For each Rmd file, render markdown (contingent on the flags set above)
  for (i in 1:dim(files.rmd)[1]) {
    if (files.rmd$md.render[i] == T) {
      out.file <- knit(as.character(files.rmd$rmd[i]), 
                      output = as.character(files.rmd$corresponding.md.file[i]),
                      envir = parent.frame(), 
                      quiet = T)
      message(paste0("KnitPost(): ", basename(files.rmd$rmd[i])))
    }     
  }
}
```

## Use bash script to call R script
I created a bash script (called `convert_rmd.sh`) under the root level of the Jekyll directory, which is adapted from the second blog. It can convert a specific R Markdown file under `_Rmd/` to Jekyll markdown under `_posts/`.

The usage is `./convert_rmd.sh _Rmd/YYYY-mm-dd-something.Rmd`. 

To support Rscript with Cygwin on Windows, I added platform check at the bottom.

```bash
#!/bin/bash
# Credit: adapted from https://chepec.se/2014/07/16/knitr-jekyll

function show_help {
  echo "Usage: convert_rmd.sh [filename.Rmd]"
  echo "Knit posts, convert Rmd to jekyll blog"
  # echo "-a convert all _Rmd/*.Rmd files to _posts/*.md (does not overwrite existing md)"
  echo "convert a specific _Rmd/*.Rmd file to _posts/*.md (overwrite existing md)"
}

if [ $# -eq 0 ] ; then
  # no args at all? show help
  show_help
  exit 0
fi

sitepath="./"
rmdfile=$1
cmd="source('./_Rmd/render_post.R'); KnitPost(site.path='$sitepath',overwriteOne='$rmdfile')"

# determine Rscript for different platforms; in particular, for Cygwin on Windows
case "$(uname -s)" in
   Darwin|Linux)
     # echo 'Mac OS X or Linux'
     Rscript -e "$cmd"
     ;;
   CYGWIN*|MINGW32*|MSYS*)
     # echo 'Windows'
     /cygdrive/c/'Program Files'/R/R-3.3.0/bin/Rscript.exe -e "$cmd"
     ;;
   *)
     echo 'other OS' 
     ;;
esac
```

## Auto-rerun when .Rmd file changes
It would be cumbersome if we need to manually rerun the above script whenener we make changes to an R Markdown file.

Also, if we could automatically rerun the above script, then we could view the generated html in the browser (locally) immediately.

To achieve this, I'm using a command called [when-changed](https://github.com/joh/when-changed). It is cross-platform and works well on Windows; other possible solutions might be `nodemon` or `inotifywait`, based on this [question](https://superuser.com/questions/181517/how-to-execute-a-command-whenever-a-file-changes).

```bash
# install when-changed
pip install https://github.com/joh/when-changed/archive/master.zip

# Usage: when-changed FILE -c COMMAND (watch FILE changes and exec COMMAND) 
when-changed _Rmd/<filename>.rmd -c bash convert_rmd.sh _Rmd/<filename>.rmd

# assume that Jekyll is also running in a different tab
jekyll serve
```
In such case, an R Markdown file will be automatically converted to `_posts/*.md`, and be further compiled to html.

## Support math equations
See [How to use MathJax in Jekyll generated Github pages](http://haixing-hu.github.io/programming/2013/09/20/how-to-use-mathjax-in-jekyll-generated-github-pages/) by Haixing Hu.

```html
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    TeX: {
      equationNumbers: {
        autoNumber: "AMS"
      }
    },
    tex2jax: {
      // inlineMath: [ ['$','$'], ['\(', '\)'] ],
      inlineMath: [ ['$','$'] ],
      displayMath: [ ['$$','$$'] ],
      processEscapes: true,
    }
  });
</script>
<script type="text/javascript"
        src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```
Note that I updated the `inlineMath` as `[ ['$','$'] ]` and CDN url to `cndjs`. The config remains the same.

## Set fig.path for different post
See [Blogging About R Code with R Markdown, Knitr, and Jekyll](https://nicolewhite.github.io/2015/02/07/r-blogging-with-rmarkdown-knitr-jekyll.html) by Nicole White.

## Sample output
Below shows a sample output, such as basic console and ggplot2, copied from [example-r-markdown.rmd](https://gist.github.com/jeromyanglim/2716336).

#### Prepare for analyses

{% highlight r %}
set.seed(1234)
library(ggplot2)
library(lattice)
{% endhighlight %}

#### Basic console output
The code chunk input and output is then displayed as follows:


{% highlight r %}
x <- 1:10
y <- round(rnorm(10, x, 1), 2)
df <- data.frame(x, y)
df
{% endhighlight %}



{% highlight text %}
##     x     y
## 1   1 -0.21
## 2   2  2.28
## 3   3  4.08
## 4   4  1.65
## 5   5  5.43
## 6   6  6.51
## 7   7  6.43
## 8   8  7.45
## 9   9  8.44
## 10 10  9.11
{% endhighlight %}

#### `ggplot2` plot
Ggplot2 plots work well:


{% highlight r %}
qplot(x, y, data=df)
{% endhighlight %}

![plot of chunk ggplot2example](/assets/Rfig/ggplot2example-1.svg)


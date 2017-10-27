#!/bin/bash
# Credit: adapted from https://chepec.se/2014/07/16/knitr-jekyll
# Program:
#   Program converts a specific R Markdown file into Markdown file 
#   with the same name and stores under _posts/ dir.
# History:
# 10/26/2017  Gaoping  First release


function show_help {
  echo "Usage: convert_rmd.sh [filename.Rmd] ..."
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

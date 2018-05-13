#!/usr/bin/env bash
# Credit: adapted from https://chepec.se/2014/07/16/knitr-jekyll
# Program:
#   Program converts a specific R Markdown file into Markdown file 
#   with the same name and stores under _posts/ dir.
# History:
# 10/26/2017  Gaoping  First release
# 05/12/2018  Gaoping  Support convert all and add warning for Windows line endings


function show_help {
  echo "Usage: convert_rmd.sh [filename.Rmd | --all] ..."
  echo "Knit posts, convert Rmd to jekyll blog"
  echo "<filename.Rmd>  convert a specific _Rmd/*.Rmd file to _posts/*.md (overwrite existing md)"
  echo "--all           convert all _Rmd/*.Rmd files to _posts/*.md (overwrite existing md)"
}

if [ $# -eq 0 ] ; then
  # no args at all? show help
  show_help
  exit 0
fi

sitepath="./"
cmd="source('./_Rmd/render_post.R')"
if [ "$1" = "--all" ]; then
  echo "convert all _Rmd/*.Rmd to _posts/*.md"
  cmd="$cmd; KnitPost(site.path='$sitepath', overwriteAll=T)"
else
  rmdfile=$1
  cmd="$cmd; KnitPost(site.path='$sitepath', overwriteOne='$rmdfile')"
fi

# determine Rscript for different platforms; in particular, for Cygwin on Windows
case "$(uname -s)" in
   Darwin|Linux)
     # echo 'Mac OS X or Linux'
     Rscript -e "$cmd"
     ;;
   CYGWIN*|MINGW32*|MSYS*)
     # echo 'Windows'
     /cygdrive/c/'Program Files'/R/R-3.3.0/bin/Rscript.exe -e "$cmd"
     echo: "Warning: remember to convert line endings to Unix style before publish"
     ;;
   *)
     echo 'other OS' 
     ;;
esac

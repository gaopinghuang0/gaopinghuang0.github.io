#!/bin/bash
# Credit: adapted from https://chepec.se/2014/07/16/knitr-jekyll

function show_help {
    echo "Knit posts, rebuild jekyll blog <Gaoping>"
    echo "Usage: convert_rmd.sh [OPTION]..."
    echo "<filename>.Rmd  convert '~/jekyll/chepec/_Rmd/<filename>.Rmd' to md in _posts"
    echo ""
    echo "--all   convert all _Rmd/*.Rmd files to _posts/*.md (does not overwrite existing md)"
    echo "-h   show this help"
}


if [ $# -eq 0 ] ; then
   # no args at all? show usage
   show_help
   exit 0
fi
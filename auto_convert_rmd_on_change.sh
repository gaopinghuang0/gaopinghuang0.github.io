#!/usr/bin/env bash
# Program:
#   Call convert_rmd.sh when Rmd file changed
# History:
# 11/03/2017  Gaoping  First release

rmdfile=$1
when-changed -v $rmdfile -c ./convert_rmd.sh $rmdfile
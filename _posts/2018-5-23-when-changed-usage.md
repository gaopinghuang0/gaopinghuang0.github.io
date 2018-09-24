---
layout: post
title: "Usage of when-changed"
author: "Gaoping Huang"
tags: bash
use_math: false
use_bootstrap: false
---

This post covers several usages for a cross-platform command: [when-changed](https://github.com/joh/when-changed). It can run a given command when a file/files/directory are changed.

## Installation
```bash
$ pip install https://github.com/joh/when-changed/archive/master.zip
```

## Basic Usage and Options
```bash
$ when-changed [-vr1s] FILE COMMAND...
# Options:
# -r Watch recursively
# -v Verbose output. Multiple -v options increase the verbosity.
#    The maximum is 3: -vvv.
# -1 Don't re-run command if files changed while command was running
# -s Run command immediately at start
```

## Sample Usages
The option `-v` is recommended to add to every usage below:
```bash
#1
$ when-changed FILE COMMAND...
#2
$ when-changed FILE [FILE ...] -c COMMAND
#3. wildcard is supported, which will be auto expanded as #2
$ when-changed FILE-with-wildcard -c COMMAND
#4
$ when-changed directory -c COMMAND

#5. `%f` gets replaced with the file that changed:
$ when-changed FILE [FILE ...] -c echo '%f changed'
$ when-changed directory -c echo '%f changed'
```
The 5th usage is particularly useful when we are watching multiple files and then execute a command for the changed file. For example,
```bash
$ when-changed -v _Rmd/*.Rmd -c echo '%f changed'

### on windows ###
# '%f' is working with cygwin built-in cmd
$ when-changed -v _Rmd -c wc '%f'
# '%f' is working with windows .exe or .bat given its absolute path
$ when-changed -v MyApp -c abs_path/to/some.[exe|bat] '%f'
# However, '%f` is not working with my `.sh` script
# because: the backslash of filename, and
# pipeline is not supported (e.g., `-c echo '%f' | xargs echo`)
$ when-changed -v _Rmd -c bash convert_rmd.sh '%f' # not working

### on linux/unix ###
$ when-changed -v _Rmd -c ./convert_rmd.sh '%f'
$ when-changed -v MyApp -c path/to/some-command '%f'
```

Note that on Windows (cygwin), we must use absolute path to a command/script (unless the command is in the same directory); On Unix, relative path is fine. For example,
```bash
# on windows
$ when-changed -v Adventure/*.jack -c F:/course/Nand2Tetris/tools/JackCompiler.bat Adventure
# on linux/unix
$ when-changed -v Adventure/*.jack -c ../../tools/JackCompiler.sh Adventure
```


# Gaoping's Blog
This blog is used to share my knowledge in programming, statistics, and machine learning. It's built on Jekyll with [Tale][Tale] Themes.

Blog address: <https://gaopinghuang0.github.io>

## Getting Started
### Install dependencies:

**Important for Windows**: 
Install ruby 2.4 from [rubyinstaller](https://rubyinstaller.org/downloads/) with DevKit. Then install the dependencies as below. If an error throws related to `eventmachine`, run `gem uninstall eventmachine` and `gem install eventmachine --platform ruby`, based on this [Github issue](https://github.com/oneclick/rubyinstaller2/issues/96#issuecomment-434619796).

~~Do not install ruby version 2.3.3 because the `eventmachine` gem is not ready for Ruby 2.4+. See https://github.com/jekyll/jekyll/issues/7221.  Once installed ruby 2.3, we need to install the devkit manually. See this [document for DevKit](https://github.com/oneclick/rubyinstaller/wiki/Development-Kit) which is not working on my current Windows 10 machine!!  Therefore, stop working on Windows (as of 11/7/2019)~~. 
```bash
$ gem install bundler  # bundler is a package manager for ruby, install it first if not yet
$ bundle update & bundle install  # install based on Gemfile
```

### Run server locally
```bash
$ bundle exec jekyll serve  --livereload

# or show draft blog posts under `_drafts/` for development
$ bundle exec jekyll serve  --livereload --draft
```

Then head to http://localhost:4000/ to see the site.

## Editing Blogs

Draft blog posts are put under `_drafts/*.md` and `_Rmd/*.Rmd` (R Markdown). For a normal `*.md` draft, once done, move to `_posts/` with proper name. For a `*.Rmd` draft, do the additional conversion as below.

To manually convert one R markdown into `_posts/*.md`, run:
```bash
$ ./convert_rmd.sh _Rmd/<filename>.Rmd
```

To watch changes and auto-convert one R Markdown into `_posts/*.md`, run:
```bash
$ when-changed _Rmd/<filename>.Rmd -c bash convert_rmd.sh _Rmd/<filename>.Rmd

# OR use a helper script
$ ./auto_convert_rmd_on_change.sh _Rmd/<filename>.Rmd
```


[Tale]: https://github.com/chesterhow/tale/
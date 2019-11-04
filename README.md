# Gaoping's Blog
This blog is used to share my knowledge in programming, statistics, and machine learning. It's built on Jekyll with [Tale][Tale] Themes.

Blog address: <https://gaopinghuang0.github.io>

## Getting Started
Install dependencies:
```bash
# ruby version 2.4.x
$ gem install bundler  # bundler is a package manager for ruby, install it first if not yet
$ bundle update & bundle install  # install based on Gemfile
```

Run server locally
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
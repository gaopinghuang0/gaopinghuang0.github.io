# Gaoping's Blog
This blog is used to share my knowledge in programming, statistics, and machine learning. It's built on Jekyll with [Tale][Tale] Themes.

Blog address: <https://gaopinghuang0.github.io>

### Getting Started
Run locally

```bash
$ jekyll serve
# or show draft blog posts under `_drafts/` for development
$ jekyll serve --draft
```

Then head to http://localhost:4000/ to see the site.

### Editing Blogs

Draft blog posts are put under `_drafts/*.md` or `_Rmd/*.Rmd` (R Markdown). To auto-convert R Markdown files into `_posts/*.md`, run:
```bash
$ when-changed _Rmd/<filename>.rmd -c bash convert_rmd.sh _Rmd/<filename>.rmd

# or use a helper script
$ ./auto_convert_rmd_on_change.sh _Rmd/<filename>.rmd
```


[Tale]: https://github.com/chesterhow/tale/
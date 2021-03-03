# Gaoping's Blog
This blog is used to share my knowledge in programming, statistics, and machine learning. It's built on Jekyll with [Tale][Tale] Themes.

Blog address: <https://gaopinghuang0.github.io>

## Getting Started
### Install dependencies:

**Important for Windows**: 
Install ruby 2.4+ from [rubyinstaller](https://rubyinstaller.org/downloads/) with DevKit. Then install the dependencies as below. If an error throws related to `eventmachine`, run `gem uninstall eventmachine` and `gem install eventmachine --platform ruby`, based on this [Github issue](https://github.com/oneclick/rubyinstaller2/issues/96#issuecomment-434619796).

```bash
$ gem install bundler  # bundler is a package manager for ruby, install it first if not yet
$ bundle update & bundle install  # install based on Gemfile
```

**For Ubuntu**, check the [Jekyll on Ubuntu](https://jekyllrb.com/docs/installation/ubuntu/).
**For MacOS**, check the [Jekyll on macOS](https://jekyllrb.com/docs/installation/macos/)

### Run server locally
```bash
$ bundle exec jekyll serve  --livereload

# or show draft blog posts under `_drafts/` for development
$ bundle exec jekyll serve  --livereload --draft
```

Then head to http://localhost:4000/ to see the site.

If there is any error related to 'Cant find gem bundler (>= 0.a) with executable bundle', check [this solution](https://bundler.io/blog/2019/05/14/solutions-for-cant-find-gem-bundler-with-executable-bundle.html).

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
The installation and description of `when-changed` can be found at my blog [Usage of when-changed](https://gaopinghuang0.github.io/2018/05/23/when-changed-usage).

### `Post.excerpts` for post in Chinese 
In the index page, it is common to show a brief description of each post. Previously, I used `truncatewords: 30`, which is not good for Chinese characters or inline code block. Based on [this Jekyll doc](https://jekyllrb.com/docs/posts/), we can use `post.excerpts`. In the `index.html`, I additionally added `strip_html` filter because the inline code block will cause some bug. 

By default, `post.excerpts` will use the first paragraph. To include multiple paragraphs as excerpts, we can set `excerpt_separator` in the front matter or `_config.yml`. For Chinese chars, the first paragraph cannot be detected properly, therefore the `excerpt_separator` is usually needed.


[Tale]: https://github.com/chesterhow/tale/
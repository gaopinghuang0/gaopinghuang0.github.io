---
layout: post
title: "Using Jekyll Themes and hosting on Github.io"
author: "Gaoping"
tags: Jekyll
---

Although there are plenty of guides introducing Jekyll and Github pages, such as [Jonathan's great guide](http://jmcglone.com/guides/github-pages/), I would like to record my own preferred way.

There are two main steps:
1. [Install Jekyll and Jekyll themes](#install-jekyll-and-jekyll-themes)
2. [Host on Github.io](#host-on-githubio)

## Install Jekyll and Jekyll themes
[Jekyll](https://jekyllrb.com/) is a static-website generator. Install Jekyll using `gem install jekyll bundler`. (Note that `bundler` is a package manager for ruby, similar to `npm` for node.js. Its config file is called `Gemfile`. You can ignore it right now.)

Although it is necessary to read the [docs][docs], I think it is faster to start with a good theme created by others.

Jekyll themes can be found at <http://jekyllthemes.org/>. I prefer [Tale][Tale] and use it as the theme of this site. Go and download the folder. You can rename the folder, such as `tale-blog`.

Below shows the directory structure of `tale-blog`:
```
.
├── CODE_OF_CONDUCT.md
├── LICENSE
├── README.md
├── _config.yml
├── _includes
│   └── head.html
├── _layouts
│   ├── default.html
│   └── post.html
├── _posts
│   ├── 2017-03-05-pagination-post.md
│   ├── 2017-03-06-the-mystery-of-the-filler-post.md
│   ├── 2017-03-07-the-case-of-the-missing-post.md
│   ├── 2017-03-10-welcome-to-jekyll.md
│   ├── 2017-03-16-example-content.md
│   └── 2017-03-29-introducing-tale.md
├── _sass
│   ├── _base.scss
│   ├── _catalogue.scss
│   ├── _code.scss
│   ├── _layout.scss
│   ├── _pagination.scss
│   ├── _post.scss
│   ├── _syntax.scss
│   └── _variables.scss
├── about.md
├── index.html
└── styles.scss
```

To see the sites locally, just run `jekyll serve`. Note that since the Tale theme is a little out of date, the configuration file `_config.yml` does not work with the latest jekyll (v3.6). Therefore, we need to update `_config.yml` first. 

Below shows an updated version:

```yaml
# Permalinks
permalink:      /:year-:month-:day/:title

# Setup
title:          My Blog
paginate:       5
baseurl:        ''
url:            "https://username.github.io"

# Assets
sass:
  sass_dir:     _sass
  style:        :compressed

# Build settings
markdown:       kramdown

# About
author:
  name:         FirstName LastName
  email:        example@gmail.com

# Gems -> plugins
plugins:
  - jekyll-paginate 
```

Then rerun `jekyll serve`. (In case of missing plugin `jekyll-paginate`, run `gem install jekyll-paginate`.) If no errors, go to `localhost:4000` and enjoy!

Now it is the right time to read the [Jonathan's great guide](http://jmcglone.com/guides/github-pages/) mentioned earlier. It explains the purpose of `_layouts`, `_includes`, and `_posts` directories. It also mentions why the files under `_posts` are named in this way. Besides, it covers how to add Google Analytics and DISQUS in our page.

Jekyll compiles everything into a directory called `_site`, which is usually added to `.gitignore`. Since some directories start with underscore (`_`), the source files (e.g., markdown and/or html) will not be copied to `_site`. Instead, only their compiled content will be stored in `_site`.

To be more specific, Jekyll basically compiles all the markdown files with [Front Matter](https://jekyllrb.com/docs/frontmatter/) into html. A usage of Front Matter is to specify the layout used to compile the markdown content, such as `layout: post` that is defined in the `_layouts` folder.

A useful feature is [writing with drafts](https://jekyllrb.com/docs/drafts/). First create a folder `_drafts` and write any `draft-post.md`. Then run `jekyll serve --drafts`, which is able to view the drafts on the site without publishing. Once any draft is done, move it to `_posts` and rename it properly.

To see more features of Jekyll, go and read its official [docs][docs].


## Host on Github.io

Here I will explain how to host a user (or organization) site, instead of a project site. First, create a new repo on Github called `<username>.github.io`. Make sure it's public. The content in the `master` branch will be automatically shown in <https://username.github.io>. While for a project site, the `gh-pages` branch or `/docs` folder on `master` is used to store source files for Pages (read more on [User, Organization, and Project Pages][1]).  

Since we are using Tale theme, we do not need to init a new README.md but just update its existing one. Next, update the `_config.yml` with proper title, name, email, and url.

I recommend to rename `tale-blog` folder to be the same as the Github repo, namely `username.github.io`. But it is optional.

I also choose to remove the LICENSE because the MIT LICENSE is not suitable for a user site.

Next, connect the local folder to the new remote repo on github.com. 

```bash
git init
git add .   # make sure that `_site` is added to .gitignore
git commit -m "init blog"
# connect local folder to remote repo
git remote add origin git@github.com:username/username.github.io.git    
git push -u origin master  # first commit
git push origin master  # after first time
```

If ok, the source code is sync to the repo on github.com. At the same time, the blog posts are shown in <https://username.github.io>.

Done!!

[Tale]: http://jekyllthemes.org/themes/tale/
[docs]: https://jekyllrb.com/docs/home/
[1]: https://help.github.com/articles/user-organization-and-project-pages/

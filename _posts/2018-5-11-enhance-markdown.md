---
layout: post
title: "Enhance Markdown with table of contents, hover anchor, on-demand Disqus, tags, and MathJax"
author: "Gaoping Huang"
tags: Jekyll
use_math: false
use_bootstrap: false
---

This post will cover some useful addons to the basic Jekyll markdown page, such as table of content, hover anchor for all headers, math expressions by MathJax, on-demand Disqus, tags, and more.


* Will be replaced with the ToC, excluding the "Contents" header
{:toc}


## Support "Table of Content"
Since `kramdown` is used as the default markdown converter, it supports automatic "Table of Content" generation. Check the [official doc](https://kramdown.gettalong.org/converter/html.html#toc).

## Support "Hover Anchor" for all headers
This part is adapted from the post [Adding hover anchor links to header on GitHub Pages using Jekyll](https://milanaryal.com/adding-hover-anchor-links-to-header-on-github-pages-using-jekyll/) by Milan Aryal.

### Step 1. Include AnchorJS
```html
<!-- make sure you include the latest version -->
<script src="//cdnjs.cloudflare.com/ajax/libs/anchor-js/4.1.0/anchor.min.js"></script>
```

### Step 2. Using AnchorJS to place icon to the left position
See <https://www.bryanbraun.com/anchorjs/>

```html
<!-- Add anchors before the closing body tag. -->
  <script>
    anchors.options.placement = 'left';
    anchors.add('.post-content > h2, .post-content > h3, .post-content > h4, .post-content > h5, .post-content > h6');
  </script>
</body>
```

### Step 3. Styling the AnchorJS icon
```css
/**
 * Link placement and hover behavior.
 */

.anchorjs-link {
  color: inherit !important;
  text-decoration: none !important; /* do not underline */
}

@media (max-width: 768px) {
  /* Do not display AnchorJS icon on less than 768px view point */
  .anchorjs-link {
    display: none;
  }
}

*:hover > .anchorjs-link {
  opacity: .75;
  /* To fade links as they appear, change transition-property from 'color' to 'all' */
  -webkit-transition: color .16s linear;
  transition: color .16s linear;
}

*:hover > .anchorjs-link:hover,
.anchorjs-link:focus {
  text-decoration: none !important; /* do not underline */
  opacity: 1;
}
```
For simplicity, we can put all the above code in a file `anchor_support.html` under `_includes/` folder. Then we just need to include it at the end of `_layouts/post.html`.

## Support math expressions by MathJax
Just follow the steps in [How to use MathJax in Jekyll generated Github pages](http://haixing-hu.github.io/programming/2013/09/20/how-to-use-mathjax-in-jekyll-generated-github-pages/) by Haixing Hu.  Since it is a little outdated, I made several updates, as below:

```html
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    TeX: {
      equationNumbers: {
        autoNumber: "AMS"
      }
    },
    tex2jax: {
      // inlineMath: [ ['$','$'], ['\(', '\)'] ],
      inlineMath: [ ['$','$'] ],
      displayMath: [ ['$$','$$'] ],
      processEscapes: true,
    }
  });
</script>
<script type="text/javascript"
        src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```
First, I updated `inlineMath` from `[ ['$','$'], ['\(', '\)'] ]` to `[ ['$','$'] ]`, in order to avoid the bug that even (1,2,3) will be parsed as math expression. This bug is also discussed in the Comments of the given blog.

Second, the CDN url is outdated and thus changed to `cdnjs.cloudflare.com`. The config of url remains the same.


## Load "DISQUS" on-demand
Showing "DISQUS" after page loading is unnecessary, especially in the development mode when livereload is enabled. So we can show it after a reader clicks the "Show Comments" button.

First of all, create a file called `disqus.html` under `_includes/` folder. The code could be copied directly from my [`_includes/disqus.html`](https://github.com/gaopinghuang0/gaopinghuang0.github.io/blob/master/_includes/disqus.html)  &#8592; **click it**. Remember to replace my `disqus_shortname` with your own forum shortname.

Then include it in the `_layouts/post.html`.

## Support "Tags"
I just used the method from [3 Simple steps to setup Jekyll Categories and Tags | Webjeda](https://blog.webjeda.com/jekyll-categories/).



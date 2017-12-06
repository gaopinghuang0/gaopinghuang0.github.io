---
layout: post
title: "Enhance Markdown with table of contents, hover anchor, on-demand Disqus, tags, and more"
author: "Gaoping Huang"
use_math: false
use_bootstrap: false
---

This post will cover some useful addons to the basic Jekyll markdown page, such as table of content, hover anchor for all headers, on-demand Disqus, tags, and more.

## Support "Table of Content"
Since `kramdown` is used as the default markdown converter, it supports automatic "Table of Content" generation. Check the [official doc](https://kramdown.gettalong.org/converter/html.html#toc).

## Support "Hover Anchor" for all headers
This part is adapted from the post [Adding hover anchor links to header on GitHub Pages using Jekyll](https://milanaryal.com/adding-hover-anchor-links-to-header-on-github-pages-using-jekyll/) by Milan Aryal.

### 1. Include AnchorJS
```html
<!-- make sure you include the latest version -->
<script src="//cdnjs.cloudflare.com/ajax/libs/anchor-js/4.1.0/anchor.min.js"></script>
```

### 2. Using AnchorJS to place icon to the left position
See <https://www.bryanbraun.com/anchorjs/>

```html
<!-- Add anchors before the closing body tag. -->
  <script>
    anchors.options.placement = 'left';
    anchors.add('.post-content > h2, .post-content > h3, .post-content > h4, .post-content > h5, .post-content > h6');
  </script>
</body>
```

### 3. Styling the AnchorJS icon
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

## Load "DISQUS" on-demand
Just use the same code as my [`_includes/disqus.html`](https://github.com/gaopinghuang0/gaopinghuang0.github.io/blob/master/_includes/disqus.html)  &#8592; **click it**.

## Support "Tags"
This seems to be a good resource: [Jekyll Tags on Github Pages](http://longqian.me/2017/02/09/github-jekyll-tag/)



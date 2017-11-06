---
layout: post
title: "Addons to Markdown, such as table of contents, hover anchor, on-demand Disqus"
author: "Gaoping Huang"
use_math: false
use_bootstrap: false
---


## Hover Anchor near header

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
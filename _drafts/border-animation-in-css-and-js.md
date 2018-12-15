---
layout: post
title: "Border Animation in CSS and JavaScript"
author: "Gaoping Huang"
tags: [SVG, JavaScript]
use_math: false
use_bootstrap: false
---

This post covers several ways of animating a path as if we are drawing it manually.

## SVG and CSS

The trick is to use the `stroke-dasharray` and `stroke-dashoffset` attributes of svg path. 

We usually use `stroke-dasharray` to render a path as dashed lines. If we set a larger value than its total length, we will see no difference. That's because the path will be rendered as a single, long dashed line (i.e., the path itself).

Then if we set `stroke-dashoffset` to some value, the path will be rendered with an offset of that value. Therefore, if we set the offset as the same value of the dasharray, the path will disappear.

By using CSS animation and gradually decreasing the value of offset, we can animate the path. Below is a Codepen demo.

<p data-height="313" data-theme-id="0" data-slug-hash="MZyvYV" data-default-tab="css,result" data-user="highfreq" data-pen-title="Border Animation with CSS and SVG" class="codepen">See the Pen <a href="https://codepen.io/highfreq/pen/MZyvYV/">Border Animation with CSS and SVG</a> by Gaoping (<a href="https://codepen.io/highfreq">@highfreq</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

However, this assumes that we already know the total length of a path. But if the path is complex or dynamically changing, we need to use JavaScript to get its length. See below.

## SVG and JavaScript

For the same SVG shape, here we first get its length by JavaScript and then set its style. The main idea is still the same.

<p data-height="312" data-theme-id="0" data-slug-hash="VqazXa" data-default-tab="js,result" data-user="highfreq" data-pen-title="Border Animation with CSS and SVG" class="codepen">See the Pen <a href="https://codepen.io/highfreq/pen/VqazXa/">Border Animation with CSS and SVG</a> by Gaoping (<a href="https://codepen.io/highfreq">@highfreq</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>


## References:
1. [How SVG Line Animation Works](https://css-tricks.com/svg-line-animation-works/) by Chris Coyier

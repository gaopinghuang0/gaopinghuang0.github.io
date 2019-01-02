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

However, this assumes that we already know the total length of a path. But if the path is complex or dynamically changing, we need to use JavaScript to get its length. See below.

## SVG and JavaScript

For the same SVG shape, here we first get its length by JavaScript and then set its style. The main idea is still the same.

<p data-height="312" data-theme-id="0" data-slug-hash="VqazXa" data-default-tab="js,result" data-user="highfreq" data-pen-title="Border Animation with CSS and SVG" class="codepen">See the Pen <a href="https://codepen.io/highfreq/pen/VqazXa/">Border Animation with CSS and SVG</a> by Gaoping (<a href="https://codepen.io/highfreq">@highfreq</a>) on <a href="https://codepen.io">CodePen</a>.</p>

## Canvas and JavaScript
For the same SVG shape, we can render it in canvas. Here, I want to use the svg path property `"M x y L x0 y0 ..."` as the input. Then we need to address two challenges.
1. Draw canvas path using the svg path. We can use the new `Path2D` API, see more from [Stack Overflow](https://stackoverflow.com/questions/9458239/draw-path-in-canvas-with-svg-path-data-svg-paths-to-canvas-paths).
2. Get the length of the path. We can use `svg-path-properties.js` to get the total length without drawing the svg path.

Note that the `Path2D` API does not support IE or Safari. I will come back to fix it if needed.

<p data-height="312" data-theme-id="0" data-slug-hash="qLPxEN" data-default-tab="js,result" data-user="highfreq" data-pen-title="Border Animation with d3 and canvas" class="codepen">See the Pen <a href="https://codepen.io/highfreq/pen/qLPxEN/">Border Animation with d3 and canvas</a> by Gaoping (<a href="https://codepen.io/highfreq">@highfreq</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

For simplicity, I use the `d3.transition` to enable the transition.


## References:
1. [How SVG Line Animation Works](https://css-tricks.com/svg-line-animation-works/) by Chris Coyier
2. [Canvas path animation using svg-path-properties](http://bl.ocks.org/rveciana/209fa7efeb01f05fa4a544a76ac8ed91)
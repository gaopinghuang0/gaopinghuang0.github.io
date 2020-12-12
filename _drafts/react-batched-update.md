---
layout: post
title: "Understanding React.js (Part 2) - Batched Updates"
author: "Gaoping Huang"
tags: [JavaScript, React]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---
When React implements the batched update mechanism. At this stage, I am focusing on an old version of React (v15.6.2), which essentially uses the [stack reconciler](https://github.com/facebook/react/tree/15-stable/src/renderers/shared/stack/reconciler). The newer version of React uses fiber reconciler, which is out of scope for this post.

<!-- 手动为一段或多段添加分隔符。这样才能正确的转换成 `post.excerpts`。 -->
<!--more-->

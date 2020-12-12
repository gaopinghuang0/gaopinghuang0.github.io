---
layout: post
title: "Understanding React.js (Part 1) - Module System and Injection"
author: "Gaoping Huang"
tags: [JavaScript, React]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---
During the process of re-implementing React.js in Typescript ([code at GitHub](https://github.com/gaopinghuang0/react-in-typescript)), I get a chance to look deeply about how React implements the batched update mechanism. At this stage, I am focusing on an old version of React (v15.6.2), which essentially uses the [stack reconciler](https://github.com/facebook/react/tree/15-stable/src/renderers/shared/stack/reconciler). The newer version of React uses fiber reconciler, which is out of scope for this post.

<!-- 手动为一段或多段添加分隔符。这样才能正确的转换成 `post.excerpts`。 -->
<!--more-->

When I first read the source code, I was very confused about the module import because each file did not use relative imports but absolute imports (e.g., `var ReactUpdates = require("ReactUpdates")`). Such type of path is typically for packages installed under `node_modules/`, but I could not find them there. The magic lies in the "Haste" module system.

### Haste Module System
For React V15, the "Haste" module system from Facebook was used. Each source file contains a license header in which it uses `@providesModule ModuleName` to declare a unique module. No matter how deep those files/modules locate, they will be eventually copied into a single flat directory called `lib/` with their unique names. Consequently, all `require("ModuleName")` will be auto converted into `require("./ModuleName")`. In other words, prepending all `require()` paths with `./`. 

Side note #1: Since the ModuleName is the same as the file name and unique, for VS Code users, it is easy to open a module by `ctrl-p` and type the module name.


Side note #2: In newer version of React, the Haste module system is replaced by [ES6 import/export](https://reactjs.org/blog/2017/12/15/improving-the-repository-infrastructure.html#removing-the-custom-module-system). The whole React architecture is split into a set of packages, which is following the pattern of [monorepo](https://danluu.com/monorepo/).

### Injection
Different renderers.  React-DOM



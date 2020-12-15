---
layout: post
title: "Understanding React.js (Part 1) - Module System and Injection"
author: "Gaoping Huang"
tags: [JavaScript, React]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---
During the process of re-implementing React.js in Typescript ([code at GitHub](https://github.com/gaopinghuang0/react-in-typescript)), I get a chance to look deeper into the source code of React. At this stage, I am focusing on an old version of React (v15.6.2), which essentially uses the [stack reconciler](https://github.com/facebook/react/tree/15-stable/src/renderers/shared/stack/reconciler). The newer version of React uses fiber reconciler, which will be covered in later posts.

<!-- 手动为一段或多段添加分隔符。这样才能正确的转换成 `post.excerpts`。 -->
<!--more-->

### Haste Module System
When I first read the source code, I was very confused about how modules are imported because each file did not use relative imports but rather absolute imports (e.g., `var ReactUpdates = require("ReactUpdates")`). Such type of path is typically for packages installed under `node_modules/`, but I could not find them there. It turns out that the magic lies in the "Haste" module system.

For React V15, the "Haste" module system from Facebook was used. Each source file contains a license header in which it uses `@providesModule ModuleName` to declare a *unique* module. No matter how deep those files/modules locate, they will be eventually copied into a single flat directory called `lib/` with their unique filenames. Consequently, all `require("ModuleName")` will be auto converted into `require("./ModuleName")`. In other words, prepending all `require()` paths with `./`. 

Side note #1: In newer version of React (V16+), the Haste module system is replaced by [ES6 import/export](https://reactjs.org/blog/2017/12/15/improving-the-repository-infrastructure.html#removing-the-custom-module-system). The whole React architecture is split into a set of packages, which is following the pattern called [monorepo](https://danluu.com/monorepo/).

Side note #2: Since the ModuleName is the same as the file name and unique, for VS Code users, it is easy to open a module by `ctrl-p` and type the module name.


### Injection
React uses Dependency Injection extensively. The package `react` has only about 2k LoC, which defines core base classes, such as `Component`, `PureComponent`, and `ReactElement`. The methods of `Component` such as `setState` are delegated to `this.updater` which is later injected by a specific renderer. There are many renderers, including `react-dom` for browser, `react-native` for mobile phone, and `react-test-renderer` which converts the virtual DOM into a string mockup for testing.

Different renderers share a core package called `react-reconciler`, which is responsible for mounting/updating/unmounting components. Inside `react-reconciler`, Dependency Injection is also used. Each renderer injects their own implementation of `HostComponent` into `react-reconciler`. For example, `react-dom` injects `ReactDOMComponent` as `HostComponent`. Also, it injects `ReactUpdateQueue` as the `updater` of `Commponent` through `ReactCompositeComponent.mountComponent`.

All default injections are defined in a module called `ReactDefaultInjection`. For example, the `BatchingStrategy` and `ReconcileTransaction` are injected into `ReactUpdates` to handle batched updates within a transaction. Moreover, `EventListener` and `EventPluginHub` are injected to handle events.

### Summary
Once I understand how the "Haste" system works, I can see its advantage that the import path can be kept really concise. Combining with VS code `ctrl-p`, it is efficient to locate each module.

Injection is definitely a good way to make React more abstract and customizable. However, this abstraction also makes it harder to locate the exact implementation of abstract instances. Fortunately, `react-dom` uses the `ReactDefaultInjection`, which specifies many key injections and saves some effort in locating their implementations.



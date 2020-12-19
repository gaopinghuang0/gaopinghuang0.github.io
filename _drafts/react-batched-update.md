---
layout: post
title: "Understanding React.js (Part 2) - Batched Updates"
author: "Gaoping Huang"
tags: [JavaScript, React]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---

React implements a batched updating mechanism for several scenarios, such as changing states via `setState` within life cycles, re-rendering component tree within a container, and calling callbacks. In this post, I will walk through the key steps that achieve the batched updating. 

Note that the source code is from an old version of React (v15.6.2). Yet, I haven't checked the newer version of React (v16+), which may have completely different ways of doing batched updating. If so, it will be very interesting to compare the difference in the future posts.

<!-- 手动为一段或多段添加分隔符。这样才能正确的转换成 `post.excerpts`。 -->
<!--more-->

The 

Transaction.  InitAll, CloseAll.
 
`ReactUpdateQueue`  getUpdateQueue

### Update caused by `setState`
_pendingStateQueue


### Update Component in Root Container

_pendingElement

### Enqueue callback
renderSubtreeIntoContainer
      ReactCurrentOwner.current = this;  <-- global variable. In ReactCompositeComponent  _renderComponent, set `this` as owner. If owner is not null, that means we are inside the render of a Component. We should not enqueue callback or setState if we are in the middle of render. For example, `getInternalInstanceReadyForUpdate` will check owner.

`enqueueCallback` is only called in `setState`, and add into `_pendingCallbacks`
      in runBatchedUpdates, stash callbacks until next render. The callbacks added to each dirty component will be moved into CallbackQueue. 
      Other callbacks will be put into CallbackQueue directly, such as didMount, didUpdate, via `getReactMountReady().enqueue()` ==> `CallbackQueue.enqueue()`. The order will be children first, parent next.

All callbacks in CallbackQueue will be invoked after the updates. Double check if it is before resetting isBatchingUpdate to false or after.  If it is before and the callback calls setState, what will happen?




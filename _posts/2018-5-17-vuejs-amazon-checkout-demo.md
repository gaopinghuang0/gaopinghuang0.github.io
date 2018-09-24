---
layout: post
title: "Vue.js Example: Amazon Checkout Page"
author: "Gaoping Huang"
tags: Vuejs
use_math: false
use_bootstrap: false
---

This is a simple Vue.js example to imitate the checkout page of Amazon.com.

The source code can be found at [amazon-checkout-examples](https://github.com/gaopinghuang0/vuejs-learning/tree/master/amazon-checkout-examples).

There are two values that will be updated accordingly: 
1. The `Billing address` will update with `Shipping address`.
2. The `Order total` and `tax` will update with the change of each item's `Quantity`. 

<!-- scale iframe content
credit: https://stackoverflow.com/a/13380454/4246348 -->
<iframe width="105%" height="620" src="//jsfiddle.net/Gaoping/ebueujjh/embedded/result,html,js,css" style="transform: scale(0.95); transform-origin: 0 0;"  allowpaymentrequest allowfullscreen="allowfullscreen" frameborder="0"></iframe>
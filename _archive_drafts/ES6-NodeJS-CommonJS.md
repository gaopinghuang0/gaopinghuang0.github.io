---
layout: post
title: "ES6 vs. CommonJS (Node.js)"
author: "Gaoping Huang"
use_math: false
use_bootstrap: false
---


## Module in ES6
```js
// util.js
function x() {}
export {x};
// or
export function x() {}

// main.js
import {x} from './util';
```
If use `export default`, then
```js
// util.js
function x() {}
export default x;
// or
export default function x() {}

// main.js
import x from './util';   // note that there is no {}
```

## Module in CommonJS

## Module (import/require, export/module.exports)
See [ES6-模块与-CommonJS-模块的差异](http://es6.ruanyifeng.com/#docs/module-loader#ES6-模块与-CommonJS-模块的差异)

```js
// in ES6
// util.js
export function x() {}
// main.js
import {x} from './util';

// in CommonJS
// util.js
function x() {}
module.exports = {
  x: x
}
// main.js
var util = require('./util');
```

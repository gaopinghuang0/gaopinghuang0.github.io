---
layout: post
title: "Typescript将 async/await 编译到ES5"
author: "Gaoping Huang"
tags: [Typescript, JavaScript]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---

`async/await` 在编写异步逻辑时非常方便。通常编译器会使用 `yield` 来实现 `async/await`。可惜的是，ES5里没有 `yield` 关键词。为了兼容 ES5，Typescript采用了一些很简洁的帮助函数 (helper functions)，模拟了 `generator` 等功能。这篇文章就简单的了解一下这个过程。

这篇文章参考了[Marius Schulz的博客](https://mariusschulz.com/blog/compiling-async-await-to-es3-es5-in-typescript)。因为这篇博客发表得较早(2016年），里面的某些帮助函数存在一些小bug，本文也会讨论后来是怎么修复的。

<!-- 如果最初的一段或几段是中文，需要手动添加分隔符。这样才能正确的转换成 `post.excerpts` -->
<!--more-->

## 简单的 async/await 例子
下面的例子中，`sleep`函数会返回一个Promise，可以被`await`。等 1s 后，函数可以接着往下执行。
```js
async function asyncAwait() {
    console.log('Before sleep');

    await sleep(1000);
    console.log('Sleep 1s');

    await sleep(1000);
    console.log('Sleep another 1s');
}

function sleep(time: number) {
    return new Promise<void>(function(resolve) {
        setTimeout(resolve, time);
    });
}

asyncAwait();
// Before sleep
// Sleep 1s
// Sleep another 1s
```

## 编译到 ES6
首先看一下怎么编译到 ES6。因为 ES6 里没有 `async/await` 关键词，所以需要用 generator 改写。

这里简单提一下怎么编译文件。
首先安装 typescript 到本地
```bash
$ npm install -D typescript
```
然后添加`tsconfig.json`，内容很简单，在`target`选项里指定编译的目标版本。
```json
{
    "compilerOptions": {
        "target": "ES6",
        "module": "commonjs"
    }
}
```

最后，使用 `npx` 调用本地 `node_modules/typescript/bin`里的`tsc`指令
```bash
$ npx tsc
```

得到的编译内容如下：
```js
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments)).next());
    });
};

function asyncAwait() {
    return __awaiter(this, void 0, void 0, function* () {
        console.log("Before sleep");
        yield delay(1000);
        console.log("Sleep 1s");
        yield delay(1000);
        console.log("Sleep another 1s");
    });
}

function sleep(time) {
    return new Promise(function(resolve) {
        setTimeout(resolve, time);
    });
}
```

其中，`sleep` 函数基本保持不变，去掉了type信息。引入了一个`__awaiter`的帮助函数，核心就是用一个`step`函数来反复调用`generator.next`。如果generator没有迭代到最后，就新建一个promise，然后将上一次的yield的值传回，即`generator.next(value)`。

这个实现是比较早的版本，有个小bug，见[GitHub issue#31552](https://github.com/microsoft/TypeScript/issues/31552)。原因在于每次`step`里都会新建一个promise。如果返回值本身就是一个promise，那么就会多加了一层，打乱EventLoop。因为微任务队列是FIFO，新建的这个promise会添加到队列最后，导致执行顺序发生变化。

解决的办法见下面，额外检查返回值是否是promise的实例。如果不是的话再包裹一层promise。
```js
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
```

## 编译到ES5/ES3
如果目标是 ES5，那么generator这个语法也不能用了。需要我们模拟一个generator，核心在于实现中断和跳转。把代码直接贴到下面：

```js
var __awaiter = // 跟上面一样，省略... 

var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
function asyncAwait() {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    console.log('Before sleep');
                    return [4 /*yield*/, sleep(1000)];
                case 1:
                    _a.sent();
                    console.log('Sleep 1s');
                    return [4 /*yield*/, sleep(1000)];
                case 2:
                    _a.sent();
                    console.log('Sleep another 1s');
                    return [2 /*return*/];
            }
        });
    });
}
// sleep() 跟上面一样，省略...
```

首先是增加了`__generator`模拟函数，内部使用了switch来模拟next或抛错误等操作。然后在asyncAwait里，原本的yield也用switch代替了，通过传回的`_a.label`来执行相应的代码片段。

可以借助Chrome里的调试工具，一步步还原出执行的细节。核心在于`asyncAwait`里每个分支返回了一个数组，例如`[4 /*yield*/, sleep(1000)]`，然后`__generator`里拿到这个数组`op`，通过`switch(op[0])`判断该采取的行动。

op[0]的可能值可以从 `typescript/src/compiler/transformers/generators.ts`里找到，包括
```js
//  0: next(value?)     - Start or resume the generator with the specified value.
//  1: throw(error)     - Resume the generator with an exception. If the generator is
//                        suspended inside of one or more protected regions, evaluates
//                        any intervening finally blocks between the current label and
//                        the nearest catch block or function boundary. If uncaught, the
//                        exception is thrown to the caller.
//  2: return(value?)   - Resume the generator as if with a return. If the generator is
//                        suspended inside of one or more protected regions, evaluates any
//                        intervening finally blocks.
//  3: break(label)     - Jump to the specified label. If the label is outside of the
//                        current protected region, evaluates any intervening finally
//                        blocks.
//  4: yield(value?)    - Yield execution to the caller with an optional value. When
//                        resumed, the generator will continue at the next label.
//  5: yield*(value)    - Delegates evaluation to the supplied iterator. When
//                        delegation completes, the generator will continue at the next
//                        label.
//  6: catch(error)     - Handles an exception thrown from within the generator body. If
//                        the current label is inside of one or more protected regions,
//                        evaluates any intervening finally blocks between the current
//                        label and the nearest catch block or function boundary. If
//                        uncaught, the exception is thrown to the caller.
//  7: endfinally       - Ends a finally block, resuming the last instruction prior to
//                        entering a finally block.
```
例如，`op[0] === 4`代表的是 yield，然后`__generator`里会让`_.label++`。这样等到返回`asyncAwait`时，就会直接访问下一个代码片段。此外，还要在`asyncAwait`里显示的return一个数组，使得`__generator`能够得知执行结束了。

跟之前`__awaiter`的情况一样，`__generator`的实现跟[之前](https://mariusschulz.com/blog/compiling-async-await-to-es3-es5-in-typescript)也有了微小的改变。比如，
```js
// old
return { next: verb(0), "throw": verb(1), "return": verb(2) };
// new
return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
```
新的代码加上了`g[Symbol.iterator]`，用来指定对象的默认迭代器，支持`for-await-of`和 rest 展开。

最后，为了让代码能正常运行，需要引入第三方的promise库，例如 Bluebird。

## 优化
`__awaiter`和`__generator`等帮助函数会在每个文件中添加，非常冗余。所以可以自己提供`__awaiter`和`__generator`，绑定到全局变量上，同时在调用tsc时带上`--noEmitHelpers`参数，这样就避免了重复。也可以使用[Marius Schulz的另一篇博客](https://mariusschulz.com/blog/external-helpers-library-in-typescript)里提到的Typescript 2.1引入的新方法。首先安装 `tslib` 依赖
```bash
$ npm install tslib --save
```
然后在编译时带上 `--importHelpers` 参数，这样生成的代码里会自动带上 `tslib.__awaiter`等方法，避免了代码重复。

## 总结
Typescript的这个编译非常简洁，通过 switch 的方式模拟了 generator 的中断和跳转。

最后，感谢一下支付宝面试我的大佬。他当时建议我看看这个实现，果然很巧妙、很有启发性。

---
layout: post
title: "JavaScript手写new, call, apply, bind"
author: "Gaoping Huang"
tags: [JavaScript]
use_math: false
use_bootstrap: false
excerpt_separator: <!--more-->
---

在前端面试时，经常考察手写 JavaScript 的 new, call, apply 和 bind。 这里把我的一些理解整理到这里，方便以后复习。

<!-- 如果最初的一段或几段是中文，需要手动添加分隔符。这样才能正确的转换成 `post.excerpts` -->
<!--more-->

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}



## 实现自己的`new`
思路是 1) 新建一个对象，把构造函数的原型传给新对象; 2) 然后用新对象为上下文，调用构造函数，如果此时有多余的参数，也一并传入; 3)如果构造函数返回了一个对象，那么就用返回的对象，舍弃新对象；否则，返回新对象。

```js
function Student(name, id) {
    this.name = name;
    this.id = id;
}
Student.prototype.sayHello = () => { console.log('hello'); }

// ES6
function myNew(Constructor, ...rest) {
    const newObj = Object.create(Constructor.prototype);
    const result = Constructor.apply(newObj, rest);
    return result instanceof Object ? result : newObj;
}

// ES5
function myNew() {
    var newObj = {};
    var Constructor = Array.prototype.shift.call(arguments);
    newObj.__proto__ = Constructor.prototype;
    var result = Constructor.apply(newObj, arguments);
    return result instanceof Object ? result : newObj;
}

// Usage
const student1 = myNew(Student, 'Tom', 1);
```
注意，`myNew`的最后一行不能使用`typeof result === 'object'`，因为如果构造函数返回值是`null`，那么`typeof null === 'object'`为true，就会导致myNew返回null。而浏览器里原生的new是会返回newObj的。对比见下图：

<img width="640" alt="myNew-comparison" style="margin:auto;" src="/assets/imgs/myNew-js.jpg">

其中，`myNew2`返回了null，跟原生的`new`结果不同。具体对比`typeof`和`instanceof`见本文的扩展部分。


## 实现自己的`bind`
最简单版本：
```js
Function.prototype.myBind = function(context, ...args) {
    if (!(this instanceof Function)) {
        throw new Error('Must bind to a function');
    }
    return (...newArgs) => {
        return this.apply(context, [...args, ...newArgs]);
    }
}
```
注意，`myBind`不能是箭头函数，否则内部的this会是创建时候的this，而不是调用myBind时候的this。但，return的function可以用箭头函数，这样就不用额外保存外部的this为fn了。

但是，如果想要支持new，就还是用传统的function。因为箭头函数既没有prototype，也不能调用call、apply、bind，这样就没办法在new的时候用新的obj来替换上下文。（见上文中实现自己的new时调用了`Constructor.apply`。）
```js
Function.prototype.myBind = function(asThis, ...args) {
    const fn = this;
    if (!(fn instanceof Function)) {
        throw new Error('Must bind to a function');
    }
    function resultFn(...newArgs) {
        return fn.apply(
            resultFn.prototype.isPrototypeOf(this) ? this : asThis,  // 用来绑定this
            [...args, ...newArgs]
        )
    }
    // 把返回函数的原型指向被绑定函数的原型。
    resultFn.prototype = fn.prototype;
    return resultFn;
}
```

## 实现自己的`call`和`apply`


```js
Function.prototype.myCall = function(context, ...args) {
    context = context || window;

    if (!(this instanceof Function)) {
        throw new Error('Must be a function');
    }
    const key = Symbol();
    context[key] = this;
    const result = context[key](...args);
    delete context[key];
    return result;
}

// 如下的例子，表明为啥需要检查 `this`是不是Function。
// 如果不检查，会抛出 "context[key] is not a function"的错误。
// 注意，用户不应该知道context[key]这种内部实现的细节，
// 所以，需要抛出一个定制的Error。
const obj = {}
obj.myCall = Function.prototype.myCall;
obj.myCall(null)  // 这时的this是obj，不是个function
```
手写apply的方法基本一样，只需要额外检查第二个参数是不是个Array。
```js
Function.prototype.myApply = function(context, argArray) {
    context = context || window;

    if (!(this instanceof Function)) {
        throw new Error('Must be a function');
    }
    if (!Array.isArray(argArray)) {
        throw new Error('The second arg must be an array');
    }
    const key = Symbol();
    context[key] = this;
    const result = context[key](...argArray);
    delete context[key];
    return result;
}
```

## 扩展

### typeof vs instanceof
见这个Stack Overflow问题：[typeof vs. instanceof](https://stackoverflow.com/questions/899574/what-is-the-difference-between-typeof-and-instanceof-and-when-should-one-be-used)。
简单来说：只有在判断简单的built-in types（string，boolean，number, symbol, bigint, undefined) 的时候，使用typeof，而不用instanceof + 大写的构造函数。其他时候都可以使用instanceof。其中，typeof null是`object`，需要额外小心。

<img width="400" alt="typeof-vs-instanceof" style="margin:auto;" src="/assets/imgs/typeof-vs-instanceof.jpg">

其实还有三个办法可以判断类型，一个是用来判断子类与父类的关系：`Foo.prototype.constructor === Base` 以及 `Object.prototype.toString.call([1]) === '[object Array]'`。前者因为constructor可能会被不小心修改或者忘记修改，那么判断会出错。后者通常用来判断是不是Array，但已经有了`Array.isArray`，用处也没有那么大。另外，Object.prototype.isPrototypeOf 可以检查一个对象是否在另一个对象的原型链上，理论上来说也可以判断类型。

### new与bind的优先级
在上面bind的代码中，一个bind后的function也能new，但问题就是这个new的时候的this是什么。

通过bind的代码看出，new绑定this的优先级大于bind，所以函数内部在new的时候会忽略掉bind传入的context。下面代码来自[美团笔试题第二题](https://juejin.im/post/6845166890990436359)，就考察了这个点：

```js
var name = 'global';
var obj = {
    name: 'local',
    foo: function() {
        this.name = 'foo';
    }.bind(window)
};
var bar = new obj.foo();
console.log(bar.name);  // ==> 'foo'
console.log(name);  // ==> 'global'
```

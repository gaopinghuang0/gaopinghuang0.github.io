---
layout: post
title: "Dig into Python super() and MRO"
author: "Gaoping Huang"
tags: [Python]
use_math: false
use_bootstrap: false
---

By reading this post, I assume you have already understood the meaning of `super()` and "MRO" in Python. Here is a short summary. MRO stands for Method Resolution Order and is used to determine how a method is looked up in class inheritance. The [C3 algorithm](https://www.python.org/download/releases/2.3/mro/) describes how to build a linearization of a class hierarchy, which is an ordered list of the ancestors, i.e., `SubClass.__mro__`.

If `super()` is not used, a method call of a subclass will follow the MRO to find the nearest parent or sibling who has the given method. Once found, it stops.

However, if `super()` is used, it is a little more complex regarding the execution order. Below is an example.

```python
class A(object):
    def go(self):
        print("A")

class B(A):
    def go(self):
        print("B1")
        super(B, self).go()
        print("B2")

class C(A):
    def go(self):
        print("C1")
        super(C, self).go()
        print("C2")

class D(B,C):
    def go(self):
        print("D1")
        super(D, self).go()
        print("D2")

D().go()
# output
# D1
# B1
# C1
# A
# C2
# B2
# D2
```

It first executes from `D.go()` to `B.go()` then to `C.go()` and eventually `A.go()`. 

At first glance, I was very confused about why the `super(B, self).go()` in `B.go()` is calling `C.go()` instead of `A.go()`, given that `A` is `B`'s parent. I realized that it follows the MRO of class D (`D.__mro__` as below), but I am still wondering what the magic is that the `super` in `B` knows that the next class is `C` instead of `A`.
```python
# (<class '__main__.D'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.A'>, <type 'object'>)
```

After digging into the CPython source code, I found a clear explanation [here](https://github.com/python/cpython/blob/master/Doc/howto/descriptor.rst#invoking-descriptors). Quoted below:
> The object returned by `super()` also has a custom `:meth:__getattribute__` method for invoking descriptors. The call `super(B, obj).m()` searches `obj.__class__.__mro__` for the base class A immediately following B and then returns `A.__dict__['m'].__get__(obj, B)`. If not a descriptor, m is returned unchanged. If not in the dictionary, m reverts to a search using `:meth:object.__getattribute__`.

> The implementation details are in `:c:func:super_getattro()` in `:source:Objects/typeobject.c`. and a pure Python equivalent can be found in [Guido's Tutorial](https://www.python.org/download/releases/2.2.3/descrintro/#cooperation).

Let's re-consider the example above according to the quoted explanation.
First, the `self` in `super(B, self).go()` is a class instance of `D`. Then the call `super(B, self).go()` will search `self.__class__.__mro__`--in our case, `D.__mro__`--for the class immediately following `B`, which is `C`. Then returns `C.__dict__['go'].__get__(self, B)`. Essentially, it calls `C.go()`.

Now the magic of `super()` and MRO is clear. Thank you for reading.


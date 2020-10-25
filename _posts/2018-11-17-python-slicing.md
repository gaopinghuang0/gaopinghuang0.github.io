---
layout: post
title: "Implementing slicing in __getitem__"
author: "Gaoping Huang"
tags: [Python]
use_math: false
use_bootstrap: false
---

Sometimes, we need to implement slicing functionality in our own class. Below is an example using slicing to get the installed Python version (copied from [six.py](https://github.com/benjaminp/six/blob/master/six.py), a Python2 and 3 compatibility library):

```python
import sys
PY34 = sys.version_info[0:2] >= (3,4)
```
Here, `sys.version_info` contains (major, minor, micro, ...). By using `[0:2]`, we get a tuple (major, minor), such as (2, 7) for Python2.7.3.

To support slicing, we need to use `object.__getitem__(self, key)` method. The `key` could be an integer or slice objects. For example,
```python
>>> class A(object):
...   def __getitem__(self, key):
...     print key
... 
>>> a = A()
>>> a[0]
0  # an integer
>>> a[0:2]
slice(0, 2, None)  # a slice object
>>> a[0:4:2]
slice(0, 4, 2)  # a slice object of (start, stop, and step)
>>> a[0,4,2]
(0, 4, 2)  # a tuple as index, which is out of our scope today
```
That is to say, a call `a[0:2]` is equivalent to `a[slice(0,2,None)]`.

With this in mind, we can customize our slicing as below:
```python
class Seq(object):
  def __init__(self, seq):
      self._seq = seq

  def get_value(self, i):
      pass

  def __getitem__(self, key):
      if isinstance(key, slice):
          start, stop, step = key.indices(len(self))
          return Seq([self[i] for i in range(start, stop, step)])
      elif isinstance(key, int):
          return self.get_value(key)
      elif isinstance(key, tuple):
          raise NotImplementedError, 'Tuple as index'
      else:
          raise TypeError, 'Invalid argument type: {}'.format(type(key))
```

### Reference:
* <http://docs.python.org/library/functions.html#slice>
* <http://docs.python.org/reference/datamodel.html#object.__getitem__>
* [Python: slicing in __getitem__ - Stack Overflow](https://stackoverflow.com/questions/2936863/python-implementing-slicing-in-getitem)

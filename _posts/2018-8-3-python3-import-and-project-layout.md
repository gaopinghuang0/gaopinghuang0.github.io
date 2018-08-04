---
layout: post
title: "Python3 import and project layout"
author: "Gaoping Huang"
tags: Python
use_math: false
use_bootstrap: false
---

My preference is to use the following project layout, where `sub1` and `sub2` are self-contained packages. Only `main.py` and `tests/*.py` are allowed to access `sub1` and `sub2`, while `sub1` cannot access `sub2`, vice versa.
```
project/
    main.py
    sub1/
        __init__.py
        helper.py
    sub2/
        __init__.py
        utils.py
    tests/
        __init__.py
        test_sub1.py
        test_sub2.py
```

The beauty is that we have no need to hack the `sys.path`. In `tests/test_sub*.py`, use relative import, such as
```python
from sub1.helper import helper
from sub2.utils import some_func
```
Then to run the test, use
```bash
$ python3 -m tests.test_sub1  # Note: not tests/test_sub1
```
Note that it must be run from the project dir, not within `tests` dir.


## Two more cases
Here, I also list two common cases where the above layout may not be satisfied.

### 1. import from parent directory

In the following layout, `config.py` is used by almost all the source files. For example, `sub1/helper.py` wants to include `config.py` from the parent directory.
```
mypackage/
    main.py
    config.py
    __init__.py
    sub1/
        __init__.py
        helper.py
```

Although we add an `__init__.py` under `mypackage/`, the `PYTHONPATH` does not contain the package. So in `helper.py`, we cannot directly use
```python
from mypackage import config
# or
from .. import config
```
, and then run under `mypackage/` (i.e., `python3 -m sub1.helper` and `python3 helper.py` are invalid). 

One possible way is to run `python3 -m mypackage.sub1.helper`, which is a little inconvenient. Anther way is to hack `sys.path`. Based on this [blog post](https://pythonadventures.wordpress.com/tag/import-from-parent-directory/) and [stackoverflow question](https://stackoverflow.com/a/11158224/4246348) by Remi, we can use
```python
import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir) 

import config
```
Note: the `__file__` attribute is not always given. Instead of using `os.path.abspath(__file__)`, Remi suggested using the inspect module to retrieve the filename (and path) of the current file.

After hacking `sys.path`, both `python3 -m sub1.helper` and `python3 helper.py` are valid now.


### 2. import from sibling directory

Again, the preferred way is to avoid importing from sibling directory (except for `main.py` or `tests/*.py`). Or else to hack `sys.path` as above. See more discussion in [Sibling package imports - stackoverflow](https://stackoverflow.com/questions/6323860/sibling-package-imports/23542795#23542795)


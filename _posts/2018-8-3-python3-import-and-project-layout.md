---
layout: post
title: "Python3 import and project layout"
author: "Gaoping Huang"
tags: Python
use_math: false
use_bootstrap: false
---

Updated on 11/4/2019. Ref: [A Typical directory structure for running tests using unittest](https://gist.github.com/tasdikrahman/2bdb3fb31136a3768fac)

My preference is to use the following project layout, where `sub1` and `sub2` are self-contained sub-packages.
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

The files under `tests/` are used to test each package/module. We can import from each package as below.
```python
from sub1.helper import helper
from sub2.utils import some_func
```

### Running a single test module
To run a single test module, in this case `test_sub1.py`:
```bash
$ python -m tests.test_sub1
```
Note that this command is running from the `project` directory, not inside `tests` directory. Also, be careful that it is `tests.test_sub1`, not `tests/test_sub1`. This is to reference a test module the same way you import it.

### Running a single test case or test method
Also you can run a single TestCase or a single test method:
```bash
$ python -m tests.test_sub1.SampleTestCase
$ python -m tests.test_sub1.SampleTestCase.test_method
```

### Running all tests
One way is to use `unittest discovery` mentioned in the [A Typical directory structure for running tests using unittest](https://gist.github.com/tasdikrahman/2bdb3fb31136a3768fac), as copied below:
```bash
$ cd new_project
$ python -m unittest discover
```
This will run all the test*.py modules inside the `tests` package.

Alternatively, we can install [pytest](https://docs.pytest.org/en/latest/). Then to run all tests:
```bash
$ pytest
```
The second option is more concise than the first one.

### Running a module in a sub-package
To run a module inside a sub-package, in this case `sub1/utils.py`. We cannot use
```bash
$ python sub1/helper.py   # may throw import error if it uses relative import
```
Instead, we should use the same technique as running a test module:
```bash
$ python -m sub1.helper
```

### Importing from a sibling directory
Sometimes, we may want to import a module/method from a sibling directory. For example, `sub1/helper.py` wants to import `sub2/utils.py`. Use:
```python
from sub2.utils import some_func
```
Then remember to run `sub1/helper.py` as a module, as mentioned above.

### Importing from parent directory

Consider the following layout, `config.py` is used by almost all source files. For example, `sub1/helper.py` wants to import `config.py` from the parent directory.
```
project/
    main.py
    config.py
    sub1/
        __init__.py
        helper.py
```
In `helper.py`, we cannot directly use:
```python
from project import config
# or
from .. import config
```

Option one is to add an `__init__.py` under `project/` to convert the root project as a package, and run `python -m project.sub1.helper` from outside of `project` directory. However, there are several drawbacks. First, it is inconvenient to call from outside with such a long command.  Second, this assumes that the root project is a pacakge, which is not always the case.

Option two is to create a virtualenv, and use `pip install -e` with a proper `setup.py`. In such case, `project` can be locally installed as a package. Agian, it is not applicable when the project is not a package.

A better option is to move `config.py` into a new subpackage, say `config/`, which contains `__init__.py` and `config.py`. Then we convert this problem into the case of importing from a sibling package, which has a solution above. More importantly, this option also works when the root project is not a package.

The last option is to hack the `sys.path` if we do not want to move `config.py` to a subpackage nor turn the project as a package. Based on this [blog post](https://pythonadventures.wordpress.com/tag/import-from-parent-directory/) and [stackoverflow question](https://stackoverflow.com/a/11158224/4246348) by Remi, we can put the below code inside a file called `environment.py`
```python
import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir) 
```
Then in `helper.py`, we first import it then import other modules.
```python
import environment  # This import can be put in each file, and will be executed for just once.
import config
```

Note: the `__file__` attribute is not always given. Instead of using `os.path.abspath(__file__)`, Remi suggested using the inspect module to retrieve the filename (and path) of the current file. After hacking `sys.path`, both `python -m sub1.helper` and `python helper.py` are valid now.


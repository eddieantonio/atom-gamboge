# Gamboge: SCIENCE BRANCH!

**Specs in this branch test the effectiveness of Gamboge against
AutoComplete, AutoComplete+, and unassisted typing.**

# How to run the evaluation

`cd` to the repository root, and then do the following:

```sh
source source_this.sh
test-gamboge
```

This will:

 - setup a virtualenv for the Python tools
 - install all Python requirements
 - place a function called `test-gamboge`

See `./evaluation_utils/upload.py` for possible arguments. (Warning:
it's a really ad hoc file).

[![Build Status](https://travis-ci.org/eddieantonio/atom-gamboge.svg)](https://travis-ci.org/eddieantonio/atom-gamboge)
/
It's like SwiftKey, but for code. In prototyping stages.

![Gamboge in Action](http://www.eddieantonio.ca/atom-gamboge/img/gamboge-0.1.0.gif)

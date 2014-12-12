# Gamboge: SCIENCE BRANCH!

**Specs in this branch test the effectiveness of Gamboge against
AutoComplete, AutoComplete+, and unassisted typing.**

**ATOM VERSION FIXED AT: v0.155.0**

# How to run the evaluation

`cd` to the repository root, and then do the following:

## First time only:

If you have downloaded a corpus using
[ghdwn](https://github.com/eddieantonio/ghdwn).

```sh
ln -s <corpus-location> corpus
```

Then install Gamboge's dependencies (both standard and testing):

```
apm install
```

_Then..._

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

It's like SwiftKey, but for code. In prototyping stages.

![Gamboge in Action](http://www.eddieantonio.ca/atom-gamboge/img/gamboge-0.1.0.gif)

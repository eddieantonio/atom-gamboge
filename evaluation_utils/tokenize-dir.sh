#!/bin/sh

DIR=$1
find $1 -name '*.py' -type f -print0 | xargs -0 py_tokenize > "$1_tokens.json"

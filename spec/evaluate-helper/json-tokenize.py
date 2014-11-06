#!/usr/bin/env python

"""
Tokenizes Python source to JSON.
"""

import fileinput
import json
import token
import tokenize

from collections import OrderedDict


def objectize(category, text, start, end, logical_line):
    return OrderedDict([
        ('category', token.tok_name[category]),
        ('text', text),
        ('start', start),
        ('end', end)
    ])

if __name__ == '__main__':
    tokens = tokenize.generate_tokens(fileinput.input().readline)
    token_list = [objectize(*tup) for tup in tokens]
    print(json.dumps(token_list))

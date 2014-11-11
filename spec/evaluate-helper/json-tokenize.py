#!/usr/bin/env python

"""
Tokenizes Python source to JSON.
"""

import fileinput
import json
import sys
import token
import flexible_tokenize as tokenize

from collections import OrderedDict


def objectize(category, text, start, end, logical_line):
    return OrderedDict([
        ('category', token.tok_name[category]),
        ('text', text),
    ])

if __name__ == '__main__':
    tokens = tokenize.generate_tokens(sys.stdin.readline)
    token_list = [objectize(*tup) for tup in tokens]
    print(json.dumps(token_list))

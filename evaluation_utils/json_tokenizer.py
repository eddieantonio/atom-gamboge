#!/usr/bin/env python

from __future__ import print_function

"""
Tokenizes Python source to JSON.
"""

import json
import sys

from collections import OrderedDict

from flexible_tokenize import generate_tokens
import token
import logging
from contextlib import contextmanager

def objectize(category, text, start, end, logical_line):
    return OrderedDict([
        ('category', token.tok_name[category]),
        ('text', text),
    ])

def tokenize_file(name):
    with open(name) as f:
        tokens = generate_tokens(f.readline)
        return [objectize(*tup) for tup in tokens]

def tokenize_stdin():
    tokens = generate_tokens(sys.stdin.readline)
    return [objectize(*tup) for tup in tokens]

def output_file(tokens, indent='', end='\n'):
    try:
        print(indent, json.dumps(tokens), sep='', end=end)
    except UnicodeDecodeError:
        # Silently ignore Unicode Decode errors because... :/
        logging.exception('Failed to decode file')
        print(indent, '[]')

def output_files(files):
    last_i = len(files) - 1
    for i, filename in enumerate(files):
        ending = '\n' if i == last_i else ',\n'
        try:
            output_file(tokenize_file(filename), indent='  ', end=ending)
        except:
            logging.exception('Failed to write a file, whoops.')

@contextmanager
def json_array():
    print("[")
    yield
    print("]")
json_array = json_array()

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 2:
        files = sys.argv[1:]
        with json_array:
            output_files(files)
    elif len(sys.argv) == 2:
        output_file(tokenize_file(sys.argv[1]))
    else:
        output_file(tokenize_stdin())


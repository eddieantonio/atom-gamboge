#!/usr/bin/env python

"""
Joins evaluation results into rows in a CSV.

Run this in the repository root.
"""

import json
import csv
import glob
from collections import defaultdict

# Key is filename.
FILES = defaultdict(dict)

FIELDNAMES = ('plain_text_keystrokes gamboge_keystrokes '
              'token_count filename ').split()


def unjsonify(filename):
    with open(filename, 'r') as f:
        return json.load(f)


def files_for_typer(name):
    files = glob.iglob('results/{name}*.json'.format(name=name))
    unjsoned = (unjsonify(f) for f in files)
    return ((f['filename'], f) for f in unjsoned)


def do_plain_text():
    for filename, val in files_for_typer('plain-text'):
        FILES[filename]['plain_text_keystrokes'] = val['keystrokes']


def do_gamboge():
    for filename, val in files_for_typer('gamboge-first-match'):
        FILES[filename]['gamboge_keystrokes'] = val['keystrokes']
        FILES[filename]['token_count'] = val['count']
        # just ignore all the other stuff.


def amend_filename():
    "Adds the file name to each 'row' in the FILES dict."
    for filename in FILES:
        FILES[filename]['filename'] = filename


def export_csv():
    amend_filename()
    skip_count = 0
    with open('simple-results.csv', 'wb') as csvfile:
        writer = csv.DictWriter(csvfile, FIELDNAMES)
        writer.writeheader()
        for row in FILES.values():
            if 'gamboge_keystrokes' not in row:
                skip_count += 1
                continue
            writer.writerow(row)
    print('Skipped %d/%d files.' % (skip_count, len(FILES)))

if __name__ == '__main__':
    do_plain_text()
    do_gamboge()
    export_csv()

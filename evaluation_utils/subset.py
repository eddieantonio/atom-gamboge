#!/usr/bin/env python
# coding: utf-8

"""
Generates an index file that is a subset of the current index file.
"""

import sys
import json

# TODO: "upload" is poor name for this module.
# Alternatively, many of the things in this module need to be moved.
from upload import context, get_index, tokens_for_repo, choose_n
from statlib import stats

import logging

def amount_of_tokens_for_repo(repo):
    logging.info("Tokenizing %r", repo)
    val = sum(len(f['tokens']) for f in tokens_for_repo(repo))
    logging.info("%d tokens in %r", val, repo)
    return val

def main():
    repos = get_index()
    datums = [(repo, amount_of_tokens_for_repo(repo)) for repo in repos]

    just_values = [value for data, value in datums]

    mean = stats.mean(just_values)
    stdv = stats.stdev(just_values)
    skew = stats.skew(just_values)

    print("µ: %r, s: %r, k: %r" % (mean, stdv, skew))

    neg_sd = mean - stdv
    pos_sd = mean + stdv
    good_repos = [repo for repo, value in datums
                  if neg_sd < value < pos_sd]

    selection = choose_n(good_repos, n=16)

    with open('new-index.json', 'w') as f:
        json.dump(selection, f)

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    sys.exit(main())

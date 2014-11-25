#!/usr/bin/env python

# Requires requests library

import sys
import fnmatch
import json
import os
import requests
import logging

from collections import namedtuple

from json_tokenizer import tokenize_file

Repo = namedtuple('Repo', 'owner name default_branch')

# Global object... to make things easier, but hackier.
class context(object):
    directory = u'corpus'
    index = None

def get_index(dirname=context.directory):
    context.directory = dirname
    with open('{}/index.json'.format(context.directory)) as index_file:
        index = json.load(index_file)
    context.index = [Repo(**repo) for repo in index]
    return context.index

def delete_corpus():
    url = 'http://localhost:5000/py/'
    r = requests.delete(url)
    # Either OK or No Content
    assert r.status_code in (200, 204)

def train_from_file(filename):
    url = 'http://localhost:5000/py/'
    with open(filename, 'rb') as f:
        r = requests.post(url, files=dict(f=f))
    assert r.status_code == 202

def python_files_from_repos(exclude={}):
    """
    List all python files from ALL repos (except the ones specified).

    >>> get_index() and None
    >>> exclusions = context.index[:261] + context.index[262:]
    >>> list(python_files_from_repos(exclude=exclusions))[0]
    u'corpus/aaronsw/html2text/html2text.py'

    """
    exclusions = set(exclude)
    for repo in context.index:
        if repo in exclusions:
            continue
        repo_root = dir_for_repo(repo)
        for filename in all_python_files(repo_root):
            yield filename

def train_corpus_excluding(repo):
    for filename in python_files_from_repos(exclude=repo):
        train_from_file(filename)

def all_python_files(repo_root):
    """
    This is the veritably worst "test" in the world.

    >>> get_index() and None
    >>> r = context.index[123]
    >>> dir_for_repo(r)
    u'corpus/iambus/xunlei-lixian'
    >>> list(all_python_files(dir_for_repo(r)))[0]
    u'corpus/iambus/xunlei-lixian/ascii_verification_code.py'
    """

    for root, _, names in os.walk(repo_root):
        for filename in fnmatch.filter(names, '*.py'):
            yield os.path.join(root, filename)

def dir_for_repo(repo):
    return os.path.join(context.directory, repo.owner, repo.name)

def tokens_for_repo(repo):
    # The root directory of the repository:
    repo_root = dir_for_repo(repo)

    files = []

    # Get every Python file in the repo...
    for filename in all_python_files(repo_root):
        entry = dict(filename=filename,
                     tokens=tokenize_file(filename))
        files.append(entry)
    return files

def json_tokens_for_repo(repo):
    r"""

    This repo has all of the UnicodeDecodeErrors...

    >>> repo = Repo('test', 'unicode_error', 'master')
    >>> json_tokens_for_repo(repo)
    '[]'
    >>> repo = Repo('test', 'hello', 'master')
    >>> '\ud83d\udca9' in json_tokens_for_repo(repo)
    True
    """
    files = tokens_for_repo(repo)
    try:
        json_string = json.dumps(files, ensure_ascii=True)
    except UnicodeDecodeError:
        logging.error('Could not JSONify tokens for %r' % (Repo,))
        json_string = '[]'

    assert '\n' not in json_string
    return json_string

def main():
    repos = get_index('corpus')

    for repo in repos:
        delete_corpus()
        train_corpus_excluding(repo)
        json_tokens = (json_tokens_for_repo(repo))
        if json_tokens == '[]':
            continue
        # Send the other process the JSONified tokens.
        # We're blocked until the other process tells us it's done.
        assert input() == 'fuzzypickles'


if __name__ == '__main__':
    sys.exit(main())

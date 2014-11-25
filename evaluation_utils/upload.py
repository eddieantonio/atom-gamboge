#!/usr/bin/env python3

# Requires requests library

import fnmatch
import hashlib
import json
import os
import requests
import shutil
import tempfile

from urllib.request import urlopen
from collections import namedtuple

Repo = namedtuple('Repo', 'owner name default_branch')

# Global object... to make things easier, but hackier.
class context(object):
    directory = 'corpus'
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

def train_corpus_excluding(repo):
    # For every file in the corpus.
    #   If the file matches the corpus name, skip it
    #   Issue the post request.
    raise NotImplemented

def md5(filename):
    """
    MD5's the given filename.
    >>> md5('/usr/share/dict/words')
    '2cf1a35b9c05153d37a1ee7465893be3'
    """
    m = hashlib.md5()
    with open(filename, 'rb') as f:
        m.update(f.read())
    return m.hexdigest()

def all_python_files(repo_root):
    """
    This is the veritably worst "test" in the world.

    >>> get_index() and None
    >>> r = context.index[123]
    >>> dir_for_repo(r)
    'corpus/iambus/xunlei-lixian'
    >>> list(all_python_files(dir_for_repo(r)))[0]
    'corpus/iambus/xunlei-lixian/ascii_verification_code.py'
    """

    for root, _, names in os.walk(repo_root):
        for filename in fnmatch.filter(names, '*.py'):
            yield os.path.join(root, filename)

def dir_for_repo(repo):
    return  os.path.join(context.directory, repo.owner, repo.name)

def move_files_to_tmpdir(repo):
    tempdir = tempfile.TemporaryDirectory()

    # The root directory of the repository:
    repo_root = dir_for_repo(repo)

    # Get every Python file in the repo...
    for source_path in all_python_files(repo_root):
        # Create the destination filename from the MD5 of the file, to
        # prevent duplicates.
        namehash = md5(source_path)
        destination = os.path.join(tempdir.name, namehash + '.py')
        # Copy it over.
        shutil.copy(original_path, destination)

    return tempdir


def main():
    repos = get_index('corpus')

    for repo in repos:
        delete_corpus()
        train_corpus_excluding(repo)
        directory = move_files_to_tmpdir(repo)
        with directory:
            # Let the other process know where to find the files.
            print(dirname)
            # We're blocked until the other process tells us it's done.
            assert input() == 'fuzzypickles'

if __name__ == '__main__':
    sys.exit(main())

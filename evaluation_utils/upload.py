#!/usr/bin/env python

# Requires requests library

import csv
import fnmatch
import gc
import json
import logging
import os
import random
import requests
import sys
import subprocess32 as subprocess

from collections import namedtuple

from json_tokenizer import tokenize_file

Repo = namedtuple('Repo', 'owner name default_branch')

logger = logging.getLogger(__name__)

basedir = os.path.dirname(os.path.dirname(__file__))


class context(object):

    "Global object... to make things easier, but hackier."
    directory = u'corpus'
    index = None
    should_train = True
    should_calculate_cross_entropy = False
    should_run_atom = True
    token_json_location = os.path.join(basedir, 'spec', 'evaluate-helper',
                                       'tokens.json')
    result_location = os.path.join(basedir, 'results')


def get_index(dirname=context.directory):
    context.directory = dirname
    with open('{}/index.json'.format(context.directory)) as index_file:
        index = json.load(index_file)
    context.index = [Repo(**repo) for repo in index]
    return context.index


def delete_corpus():
    # Skip silently...
    if not context.should_train:
        return

    logger.debug('Deleting corpus...')
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

    # Skip silently...
    if not context.should_train:
        return

    exclusions = set(exclude)
    for repo in context.index:
        if repo in exclusions:
            continue
        logger.debug('Will train %r', repo)
        repo_root = dir_for_repo(repo)
        for filename in all_python_files(repo_root):
            yield filename


def calculate_cross_entropy(filename):
    url = 'http://localhost:5000/py/xentropy'

    logger.debug('Requesting cross-entropy for %s', filename)
    with open(filename, 'rb') as f:
        r = requests.post(url, files=dict(f=f))
    assert r.status_code == 200
    content = r.json()
    return content['cross_entropy']


def train_corpus_excluding(repo):
    logger.info('Training everything EXCEPT %r', repo)
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
    "Tokenizes ALL OF THE FILES in the repo"
    # The root directory of the repository:
    repo_root = dir_for_repo(repo)

    files = []

    # Get every Python file in the repo...
    for filename in all_python_files(repo_root):
        entry = dict(filename=filename,
                     tokens=tokenize_file(filename))
        files.append(entry)
    return files


def calculate_per_file_repo_cross_entropy(repo):
    for filename in all_python_files(dir_for_repo(repo)):
        entropy = calculate_cross_entropy(filename)
        yield filename, entropy


def json_tokens(files, repo):
    r"""

    This repo has all of the UnicodeDecodeErrors...

    >>> repo = Repo('test', 'unicode_error', 'master')
    >>> json_tokens_for_repo(repo)
    '[]'
    >>> repo = Repo('test', 'hello', 'master')
    >>> '\ud83d\udca9' in json_tokens_for_repo(repo)
    True
    """
    try:
        json_string = json.dumps(files, ensure_ascii=True)
    except UnicodeDecodeError:
        logger.error('Could not JSONify tokens for %r', repo)
        json_string = '[]'

    return json_string


def write_json_tokens(contents):
    if contents == '[]':
        return False

    location = context.token_json_location
    with open(location, 'wb') as f:
        f.write(contents)

    logger.debug("Wrote tokens to '%s'", location)
    return True


def write_cross_entropy(repo):
    if not context.should_calculate_cross_entropy:
        return

    xentropies = calculate_per_file_repo_cross_entropy(repo)
    name = "{}-{}.csv".format(repo.owner, repo.name)
    location = os.path.join(basedir, 'xentropy', name)
    with open(location, 'wb') as f:
        writer = csv.writer(f)
        for info in xentropies:
            writer.writerow(info)

    logger.info("Wrote xentropies for %s for %s", location, repo)


def run_atom(repo):
    # run apm test
    if not context.should_run_atom:
        return
    logger.info('Running Atom...')
    status = subprocess.call(['apm', 'test'])
    if status != 0:
        logger.warn('Atom returned with %d status on %r', status, repo)


def config_logging():
    # Set up a the logger...
    from big_dumb_filter import BigDumbFilter

    logging.getLogger(__name__).addFilter(BigDumbFilter())
    logging.getLogger("requests").setLevel(logging.WARNING)

    if '--debug' in sys.argv:
        debug_fmt = '%(bgcolor)s%(levelname)8s => %(message)s\033[m'
        logging.basicConfig(level=logging.DEBUG, format=debug_fmt)
    else:
        standard_fmt = '%(bgcolor)s    %(asctime)5s %(message)s\033[m'
        logging.basicConfig(level=logging.INFO,
                            format=standard_fmt,
                            stream=sys.stderr,
                            datefmt='%H:%M')


def choose_n(seq, n=8):
    "Choose n elements from the list."
    as_list = list(seq)
    random.shuffle(as_list)
    return as_list[:n]


def main(*args):
    repos = get_index('corpus')

    # "parse args"
    if '--no-train' in args:
        logger.info('Will NOT train for this run.')
        context.should_train = False

    if '--xentropy' in args:
        logger.info('Will calculate cross entropy of each file.')
        context.should_calculate_cross_entropy = True
        if not context.should_train:
            logger.warn('Cross-entropy without training is strange.')

    if '--no-atom' in args:
        context.should_run_atom = False

    for repo in choose_n(repos, n=8):
        delete_corpus()
        train_corpus_excluding(repo)
        # Do this first because of a bug in UnnaturalCode...
        write_cross_entropy(repo)
        for tokenizedFile in tokens_for_repo(repo):
            # So this takes a list of a single element because... uh...
            # historical reasons... Yeah.
            if write_json_tokens(json_tokens([tokenizedFile], repo)):
                run_atom(repo)

        # Force a collection... just to be sure.
        gc.collect()

if __name__ == '__main__':
    config_logging()
    sys.exit(main(*sys.argv))

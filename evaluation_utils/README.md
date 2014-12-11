# Evaluation Runner

Runs the evaluation with the following algorithm.

    for each project in corpus:
        delete existing language model
        train new language model with all projects *except* this one
        write tokens from this project to `tokens.json`
        run `apm test`

Why do I:

  1. Delete the corpus?

    > It's easier than "untraining" the corpus.

  2. Write a new `tokens.json` file and run `apm test` from Python?

    > Having Atom be the boss causes me to write disgusting asynchronous
    code trying to be synchronous with the Python file. This way causes
    less headaches, and the overhead is managable.

Includes utilities to tokenize Python 2 code and to retrain corpora
through the HTTP interface to UnnaturalCode.

**NOTE**: You'll need to add a symlink to your corpus labelled `corpus`
to run the "tests".

module.exports =
  # Encodes realistic entropies.
  'after for i in': [
    [0.337218, ["in", "range" ] ]
    [0.345281, ["in", "range", "(" ] ]
    [1.85889,  ["in", "range", "(", "5" ] ]
    [2.08747,  ["in", "range", "(", "5", ")" ] ]
    [2.21087,  ["in", "range", "(", "10" ] ]
    [2.40771,  ["in", "range", "(", "10", ")" ] ]
  ]

  'start of file': [
    [1,   ['import', 'os', '<NEWLINE>']]
    [2,   ['import', 'sys', '<NEWLINE>']]
    [3,   ['import']]
  ]

  # One suggestion, all whitespace.
  'after for i in range(10):': [
    [1,   ['<NEWLINE>', '<INDENT>']]
    # Should probably add more here...
  ]

  # One suggestions, mixed normal and whitespace
  'after if __name__ ': [
    # UnnaturalCode actually won't predict this ever, because of the way that
    # it is...
    [0.5, ['==', '__main__', ':', '<NEWLINE>', '<INDENT>']]
  ]

  # Two suggestions, (second is 'infinitely unlikely')
  # - Dedent token
  # - Dedent token + normal token
  'after return False': [
    [1, ['<DEDENT>']]
    [70, ['<DEDENT>', 'def']]

  ]

  # When you just want some predictions in the test. Text is always '...'
  ellipsis: [
    # I love how this is syntactically valid in Python 3
    [1, ['...']],
    [70, ['...', 'or', '...']]
  ]


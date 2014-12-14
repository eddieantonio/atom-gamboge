# # Gamboge
#
# First match semantics. Picks the first match in the list.
# Might need to include whether it's the longest match in the list.
#
# # Required data:
#
# ## Per file
#
#  - keystroke count
#
# ## Per token
#
#  - token in list? (-> were suggestions useful?, how many misses?)
#  - where in the list is the suggestion?
#  - length of suggestion taken per list (-> is multi-token worth it?)
#  - how long is the list? (-> MRR)
#
module.exports = (tokens, done) ->
  index = 0         # Index of the current token to type.
  count = 0         # Amount of keystrokes
  logicalIndent = 0 # Used for indenty stuff.
  editor = @editor  # Fat arrows are dumb
  tokenStats = []   # Stuff about each token in the editor.
  editorView = atom.views.getView(editor)

  # Helpers (bound by closure).
  currentIndentLevel = =>
    lineNum = editor.getLastBufferRow()
    editor.indentationForBufferRow(lineNum)

  # Normal typer
  typeItLikeABigOlDoofus = (text, category) ->
    delta = switch category
      when 'INDENT'
        # Auto-indent means no key press.
        logicalIndent += 1
        0
      when 'DEDENT'
        logicalIndent -= 1
        editor.backspace()
        1
      when 'NEWLINE'
        doNewLine()
      when 'NL'
        doUnimportantNewline()
        1
      when 'ENDMARKER'
        0
      else
        # The space thing is an issue for verifying comments, but I don't
        # really care at this point.
        typedText = if category is 'COMMENT' then text else "#{text} "
        editor.insertText typedText
        text.length
    keystrokes: delta
    tokenDelta: 1
    tokenInfo: {inList: no, pos: null, size: PLIST.length()}

  nextSuggestion = () ->
    atom.commands.dispatch(editorView, 'gamboge:next-prediction')

  useSuggestion = () ->
    atom.commands.dispatch(editorView, 'gamboge:complete-all')

  forcePredict = () ->
    atom.commands.dispatch(editorView, 'gamboge:show-suggestions')

  # Plain-text Handlers
  doNewLine = ->
    backspaceCounter = 0

    # When we've indented BUT the next syntax-relevant token isn't an
    # indent, then we gotta backspace:
    editor.insertNewlineBelow()
    unless nextImportantTokenIsIndent(tokens, index)
      while currentIndentLevel() > logicalIndent
        editor.backspace()
        backspaceCounter++

    1 + backspaceCounter

  doUnimportantNewline = ->
    # <NL> are just newlines that are ignored by the syntax.
    indentLevelBeforeNewline = currentIndentLevel()
    editor.insertNewlineBelow()

  # THE GAMBOGE TYPER
  gambogeIt = (text, category) ->
    if not PLIST.length()
      # No predictions? Skip fast!
      return null

    info = indexOfFirstMatch(tokens, index, PLIST._predictions)
    # Miss!
    return null if not info?

    for _ in [0...info.index]
      nextSuggestion()
    useSuggestion()

    keystrokes: info.index + 1 # suggestion down + complete-all
    tokenDelta: info.index
    tokenInfo:
      inList: yes
      pos: info.index
      size: PLIST.length()
      tokenLen: info.tokens.length

  typeNextTokens = () ->
    if not tokens[index]?
      # No more tokens left to type... :C
      return done({keystrokes: count, tokens: tokenStats})


    {text, category} = tokens[index]
    # Try the standard typer.
    info = gambogeIt(text, category)
    # Back off to the standard typer.
    info = typeItLikeABigOlDoofus(text, category) if not info?

    {keystrokes, tokenInfo, tokenDelta} = info

    tokenStats = tokenStats.concat(tokenInfo)
    count += keystrokes

    index += tokenDelta
    # The next prediction SHOULD start now...
    forcePredict()

  # FINALLY THE PART THAT DOES STUFF!
  PLIST.onDidChangePredictions (info) ->
    typeNextTokens()

  # Get the first prediction!
  forcePredict()


# Return: {Boolean} whether next "important" token is an indent.
nextImportantTokenIsIndent = (tokens, i)->
  j = 1
  while i + j < tokens.length
    # Skip over <NL> and <COMMENT> tokens...
    if tokens[i + j].category not in ['NL', 'COMMENT']
      break
    j += 1

  tokens[i + j]?.category is 'INDENT'

# Returns the index, tokens, and entropy of the first matching suggestion or
# null.
indexOfFirstMatch = (originalTokens, tokenStart, suggestionList) ->
  for suggestion, index in suggestionList
    {tokens, entropy} = suggestion
    if matchesSuggestion(originalTokens, tokenStart, tokens)
      return {index, tokens, entropy}
  return null

# Does the token at position i match suggestion?
matchesSuggestion = (tokens, i, suggestion) ->
  for suggestedToken, j in suggestion
    return false if not tokensMatch(tokens[i + j], suggestedToken)
  return true

# Does the full token match the suggestion text?
tokensMatch = (token, suggestion) ->
  switch token.category
    when 'NL', 'NEWLINE' then suggestion in ['<NL>', '<NEWLINE>']
    when 'DEDENT' then suggestion is '<DEDENT>'
    when 'INDENT' then suggestion is '<INDENT>'
    else suggestion is token.text
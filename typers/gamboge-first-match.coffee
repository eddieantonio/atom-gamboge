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
  i = 0
  count = 0
  logicalIndent = 0
  editor = @editor
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
    {keystrokes: delta}

  nextSuggestion = () ->
    atom.commands.dispatch(editorView, 'gamboge:next-prediction')

  useSuggestion = () ->
    atom.commands.dispatch(editorView, 'gamboge:complete-all')

  forcePredict = () ->
    atom.commands.dispatch(editorView, 'gamboge:show-suggestions')

  # Standard Handlers
  doNewLine = ->
    backspaceCounter = 0

    # When we've indented BUT the next syntax-relevant token isn't an
    # indent, then we gotta backspace:
    editor.insertNewlineBelow()
    unless nextImportantTokenIsIndent(tokens, i)
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
    {}

  typeNextTokens = (index) ->
    return done({keystrokes: 0})

    {text, category} = tokens[index]
    info = {keystrokes, tokenInfo, tokenDelta} = gambogeIt(text, category)

    # Back off to the standard typer.
    if not info?
      {keystrokes, tokenInfo} = typeItLikeABigOlDoofus(text, category)
      tokenDelta = 1

    tokenStats.push(tokenInfo)
    count += keystrokes
    typeNextToken(index + 1)


  # FINALLY, THE ACTAUL PART THAT DOES THINGS:
  tokenStats = []

  PLIST.onDidChangePredictions (info) ->
    typeNextTokens(i)

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

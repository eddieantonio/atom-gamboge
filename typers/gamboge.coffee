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
# TODO: This is just the plain-text typer!
module.exports = (tokens) ->
  count = 0
  logicalIndent = 0

  currentIndentLevel = =>
    lineNum = @editor.getLastBufferRow()
    @editor.indentationForBufferRow(lineNum)

  nextImportantTokenIsIndent = (tokens, i)->
    j = 1
    while i + j < tokens.length
      # Skip over <NL> and <COMMENT> tokens...
      if tokens[i + j].category not in ['NL', 'COMMENT']
        break
      j += 1

    tokens[i + j]?.category is 'INDENT'

  for token, i in tokens
    {text, category} = token
    delta = switch category
      when 'INDENT'
        # Auto-indent means no key press.
        logicalIndent += 1
        0
      when 'DEDENT'
        logicalIndent -= 1
        @editor.backspace()
        1
      when 'NEWLINE'
        backspaceCounter = 0

        # When we've indented BUT the next syntax-relevant token isn't an
        # indent, then we gotta backspace:
        @editor.insertNewlineBelow()
        unless nextImportantTokenIsIndent(tokens, i)
          while currentIndentLevel() > logicalIndent
            @editor.backspace()
            backspaceCounter++

        1 + backspaceCounter
      when 'NL'
        # <NL> are just newlines that are ignored by the syntax.
        indentLevelBeforeNewline = currentIndentLevel()
        @editor.insertNewlineBelow()
        console.assert(currentIndentLevel() is indentLevelBeforeNewline)
        1
      when 'ENDMARKER'
        0
      else
        @editor.insertText text
        # I forgot why I did this. I think because it changes the shebang
        # line?
        unless category is 'COMMENT'
          @editor.insertText ' '
        text.length

    count += delta

  keystrokes: count

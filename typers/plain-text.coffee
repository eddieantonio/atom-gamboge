module.exports = (tokens) ->
  count = 0
  logicalIndent = 0

  currentIndentLevel = =>
    lineNum = @editor.getLastBufferRow()
    @editor.indentationForBufferRow(lineNum)

  for token, i in tokens
    {text, category} = token
    console.log "[#{category}] #{text}..."
    delta = switch category
      when 'INDENT'
        # Auto-indent means no key press.
        logicalIndent += 1
        0
      when 'DEDENT'
        logicalIndent -= 1
        @editor.backspace()
        1
      when 'NEWLINE', 'NL'
        backspaceCounter = 0
        # When we've indented BUT the next token isn't an indent...
        @editor.insertNewlineBelow()
        unless tokens[i + 1]?.category is 'INDENT'
          while currentIndentLevel() > logicalIndent
            console.log 'Backspace!'
            @editor.backspace()
            backspaceCounter++
        1 + backspaceCounter
      when 'ENDMARKER'
        0
      else
        @editor.insertText text
        # I forgot why I did this. I think because it changes the shebang
        # line?
        unless category is 'COMMENT'
          @editor.insertText ' '
        text.length

    console.log "...#{delta} keystrokes"
    count += delta
    

  keystrokes: count


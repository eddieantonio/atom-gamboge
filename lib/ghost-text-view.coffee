# Not to be confused with GhostScript utility...

{View} = require 'atom'

# A SpacePen view for
class GhostTextView extends View
  tokens: []

  @content: (tokens) ->
    @div class: 'gamboge-ghost', =>
      for token in tokens
        if token of specialChars
          @span specialChars[token], class: 'gamboge-invisible'
        else @text token
        # Add a space, just to make sure we're still sane.
        @text ' '

# Keys are special tokens that are represented by internal characters.
specialChars = do ->
  mkInvisibleGetter = (prop) ->
    get: -> atom.config.get('editor.invisibles')[prop]
    enumerable: yes

  Object.create null,
    '<NEWLINE>': mkInvisibleGetter 'cr'
    '<NL>': mkInvisibleGetter 'cr'
    '<INDENT>': mkInvisibleGetter 'tab'
    'DEDENT':
      get: -> atom.config.get('gamboge.dedentMarker')
      enumerable: yes


module.exports = {GhostTextView, specialChars}

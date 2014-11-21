# Copyright (C) 2014  Eddie Antonio Santos
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Makes a bunch of indents!
makeIndents = (string, times) ->
  console.assert times >= 0
  if times < 1 then ''
  else (string for _ in [1..times]).join('')


# Formats tokens! Especially useful
class TextFormatter
  # Requires a TextEditor.
  constructor: ({@getIndentLevel, @getIndentChars}) ->

  # Returns a proper string for the given string.
  format: (tokens) ->
    text = ""
    @additionalIndent = 0

    for i in [0...tokens.length]
      # Have a peek token.
      [token, peekToken] = [tokens[i], tokens[i + 1]]
      text +=
        if token of @specialTokens
          @specialTokens[token].call(@, peekToken)
        else
          "#{token} "
    text

  # Internal: Emits a newline PLUS the next indentation.
  handleNewline: (peek) ->
    indentLevel =
      @getIndentLevel() + @additionalIndent - (peek is '<DEDENT>')
    "\n#{makeIndents @getIndentChars(), indentLevel}"

  specialTokens:
    '<NEWLINE>': TextFormatter::handleNewline
    '<NL>': TextFormatter::handleNewline
    '<INDENT>': ->
      @additionalIndent++
      # Simply emits the indent string.
      @getIndentChars()
    '<DEDENT>': ->
      @additionalIndent--
      console.assert @additionalIndent >= 0
      # Nothing to output since handleNewline's already got this.
      ''

  # Internal: Returns an 'indent spy' based on the given TextEditor instance.
  #
  # An indent spy is an object that contains these properties:
  #
  #  * getIndentChars: {Function} that returns the string used to indent a
  #                    line. For example, a tab for tab indents, or two
  #                    spaces for 2 space indents
  #  * getIndentLevel: {Function} that returns the indent level for the
  #                    current buffer line.
  @makeEditorIndentSpy: (editor) ->
    getIndentChars: editor.getTabText.bind(editor)
    getIndentLevel: ->
      {row} = editor.getCursorBufferPosition()
      editor.indentationForBufferRow(row)

module.exports = TextFormatter

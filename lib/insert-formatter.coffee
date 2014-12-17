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

# Newline PLUS the next indentation
newlineHandler =  (peek) ->
  indentLevel = @getIndentLevel() - (peek is '<DEDENT>')
  indent = makeIndents @getIndentChars(), indentLevel

  "\n#{indent}"

# Formats tokens! Especially useful
class InsertFormatter
  # Requires a TextEditor.
  constructor: ({@getIndentLevel, @getIndentChars}) ->

  # Returns a proper string for the given string.
  format: (tokens) ->
    text = " "
    for i in [0...tokens.length]
      # Have a peek token.
      [token, peekToken] = [tokens[i], tokens[i + 1]]
      text +=
        if token of @specialTokens
          @specialTokens[token].call(@, peekToken)
        else
          "#{token} "
    text

  specialTokens:
    '<NEWLINE>': newlineHandler
    '<NL>': newlineHandler
    # Simply emit the indent string...
    '<INDENT>': (editor) -> @getIndentChars()
    # This is a no-op since the newline handles this stuff already!
    '<DEDENT>': () -> ''


module.exports = {InsertFormatter}

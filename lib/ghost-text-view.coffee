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

# Not to be confused with GhostScript utility...

{View} = require 'space-pen'

# A SpacePen view for
class GhostTextView extends View
  @content: (tokens) ->
    @div class: 'gamboge-ghost', =>
      for token in tokens
        @text ' '
        if token of specialChars
          @span specialChars[token], class: 'gamboge-invisible'
        else @text token
        # Add a space, just to make sure we're still sane.

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

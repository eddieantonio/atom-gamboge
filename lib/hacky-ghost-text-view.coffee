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

{Point} = require 'atom'
{CompositeDisposable} = require 'event-kit'
{View} = require 'space-pen'


module.exports=
class HackyGhostView
  subscriptions = new CompositeDisposable
  $view = null

  constructor: (predictions, @$editor) ->
    subscriptions.add predictions.onDidChangeIndex (index) =>
      # TODO
    subscriptions.add predictions.onDidInvalidate (index) =>
      @removeAll()
    subscriptions.add predictions.onDideChangePredictions (index) =>
      # TODO

  setAt: (inPosition) ->
    position = Point.fromObject(inPosition)
    throw new Error('not implemented')
    # TODO

  removeAll: ->
    # TODO

  destroy:
    subscriptions.dispose()


# A SpacePen view for
class GhostTextView extends View
  @content: (tokens) ->
    @div class: 'gamboge-ghost', =>
      for token in tokens
        # Add a space, just to make sure we're still sane.
        @text ' '
        if token of specialChars
          @span specialChars[token], class: 'gamboge-invisible'
        else
          @text token

# Keys are special tokens that are represented by internal characters.
specialChars = do ->
  mkInvisibleGetter = (prop, prefix='editor.invisibles') ->
    get: -> atom.config.get(prefix)[prop]
    enumerable: yes

  Object.create null,
    '<NEWLINE>': mkInvisibleGetter 'cr'
    '<NL>': mkInvisibleGetter 'cr'
    '<INDENT>': mkInvisibleGetter 'tab'
    '<DEDENT>': mkInvisibleGetter 'dedentMarker', 'gamboge'

module.exports = {GhostTextView, specialChars}

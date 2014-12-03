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
{$, View} = require 'space-pen'

#FIXME: Temporary thing for pretty output on MY screen.
if process.env.TERM_PROGRAM is 'iTerm.app' and process.env.USER is 'eddieantonio'
  pe = require('pretty-error').start()
  pe.skipNodeFiles()
  pe.skipPackage('q')
  pe.skipPath('/Applications/Atom.app/Contents/Resources/app/vendor/jasmine.js')

module.exports =
class HackyGhostView
  subscriptions: null
  $view: null

  constructor: (predictions, @$editor) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add predictions.onDidChangeIndex (index) =>
      return if not predictions.current()?

      {tokens, position} = predictions.current()
      console.assert tokens.length >= 1
      console.assert position.length is 2
      @setAt tokens, position

    @subscriptions.add predictions.onDidInvalidate (index) =>
      @removeAll()

    @subscriptions.add predictions.onDidChangePredictions (index) =>
      # TODO: Should anything even go in here?

  setAt: (tokens, position) ->
    [row, column] = position

    # XXX: This is a *disgusting* and fragile way to add the ghost-text; I
    # easily expect this to be broken in in the near future. I really
    # shouldn't be messing around with the editor DOM, but it's effective as
    # long as we're responsible with it...
    $row = $(".line[data-screen-row=#{row}]")
    console.assert not $row.empty()

    $sourceSpan = $row.children('.source, .text').first()
    @$ghostText = new GhostTextView(tokens)

    # TODO: place the element at the given column!
    $sourceSpan.append @$ghostText

    # This class will be useful in selectors.
    @$editor.addClass 'gamboge'

  removeAll: ->
    @$editor.find('.gamboge-ghost, .gamboge-invisible').remove()
    @$editor.removeClass 'gamboge'
    @$ghostText = null

  destroy: ->
    @subscriptions.dispose()


# A SpacePen view for a single continuous stretch of ghost-text.
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

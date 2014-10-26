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

{$, Point, Range, View} = require 'atom'
_ = require 'underscore-plus'


{GhostTextView} = require './ghost-text-view'
PredictionList = require './prediction-list'

# This class listens to editor events, forwarding state, and updating a model. In
# effect, this is kind of a View/Controller in classical MVC.
#
# It is primarily concerned with getting surrounding token context, receiving
# predictions, and forwarding display of predictions (through [INSERT CLASS
# HERE]).

# Use at most this many tokens to form predictions.
NGRAM_ORDER = 4

# TODO: Refactor Gamboge event listener from this.
# TODO: GambogeView IS NOT a View!

# Note: Heavily based on: atom/autocomplete, (C) GitHub Inc. 2014
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee
module.exports =
class GambogeView extends View
  editor: null
  buffer: null
  $ghostText: null

  predictionMarker: null
  predictionTextRange: null

  predictionList: new PredictionList

  @content: ->
    # TODO: look-up these classes! overlay from-top
    @div class: 'gamboge hidden'

  initialize: (@editor) ->
    @editorView = $(atom.workspace.getView(@editor))
    @buffer = @editor.getBuffer()
    @grammar = @editor.getGrammar()

    # This class will be useful in selectors.
    @editorView.addClass 'gamboge'

    # LISTEN TO ALL OF THE EVENTS!
    @registerEvents()

  registerEvents: ->
    console.log 'Registering events...'
    # Updates the prediction model.
    # Invoked 300ms after last buffer change.
    # TODO: use `onDidChange` instead?
    @editor.onDidStopChanging =>

      text = @getTextForCursorContext()

      console.log predicting_for: text

      # Set off prediction request
      @predict text, (predictions) =>
        return unless predictions?
        @predictionList.setPredictions predictions

    @predictionList.onDidChangePredictions =>
      @showGhostText @predictionList._predictions

    # TODO: onDidChangePath will probably be useful later for telling the
    # prediction back-end that stuff changed.

    @editor.onDidChangeCursorPosition =>
      # TODO: Change model stuff here!

    @subscribeToCommand @editorView, 'gamboge:show-suggestions', =>
      # TODO....
    @subscribeToCommand @editorView, 'gamboge:show-ghost-text', =>
      # TODO...

    # Super future TODO: onDidChangeGrammar
    # This... might be useful?

  # Using markers, shows the GhostText.
  showGhostText: (predictions) ->
    return unless predictions.length

    # TODO: Do something better than this...
    firstPrediction = @predictionList.current().tokens

    # Get a marker for the place immediately adjacent the cursor.
    afterCursor = @editor.getCursorBufferPosition()

    # Oh dear...
    {row, column} = @editor.getCursorScreenPosition()

    # TODO: Check if the cursor is on screen!

    @predictionMarker = @editor.markBufferPosition afterCursor,
      invalidate: 'touch'
      persistent: no

    # XXX: This is a *disgusting* and fragile way to add the ghost-text; I
    # easily expect this to be broken in future versions in the near future. I
    # really shouldn't be messing around with the editor DOM, but it's
    # effective as long as we're responsible with it...
    $row = $(".line[data-screen-row=#{row}]")
    $sourceSpan = $row.children('.source, .text').first()
    @$ghostText = new GhostTextView(firstPrediction)
    # TODO: place the element where the *cursor* is!
    $sourceSpan.append @$ghostText

    @predictionMarker.onDidChange (marker) =>
      @destroyMarker() unless marker.isValid

  # Get rid of the prediction marker and any annotation associated with it.
  destroyMarker: ->
    console.log 'Destroying marker'
    @predictionMarker?.destroy()
    @predictionMarker = null
    @unshowGhostText()


  unshowGhostText: ->
    @editorView.find('.gamboge-ghost').remove()
    console.log @$ghostText
    @$ghostText = null
    @editorView.removeClass('.gamboge')

  # Gets a whole bunch of text prior to the cursor.
  getTextForCursorContext: ->
    # Get text for the current line.
    cursorPosition = @editor.getCursorBufferPosition()
    beginningOfLine = new Point(cursorPosition.row, 0)
    contextRange = new Range(beginningOfLine, cursorPosition)

    # TODO: Get more text than just the current line.
    @editor.getTextInBufferRange(contextRange)


  # Internal: Do the prediction, calling `done(maybeData)` when finished.
  # maybeData can be null, to indicate that the prediction did not succeed.
  predict: (text, done) ->
    origin = atom.config.get 'gamboge.unnaturalRESTOrigin'

    # TODO: use @grammar.name => But need a look-up table for the language...
    lang = 'py'

    url = "http://#{origin}/#{lang}/predict/"
    xhr = new XMLHttpRequest()
    xhr.open('POST', url, yes)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
    xhr.addEventListener 'load', =>
      return done(null) unless xhr.status is 200
      {suggestions} = JSON.parse(xhr.responseText)
      done(suggestions)
    xhr.send("s=#{encodeURIComponent(text)}")

  # Tear down any state and detach.
  destroy: ->
    @editorView.removeClass 'gamboge'
    @detach()

# TODO: Make a popover suggestion list ACTUALLY based on autocomplete!
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee

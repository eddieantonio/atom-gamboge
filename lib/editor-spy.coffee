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

{Point, Range, View, CompositeDisposable} = require 'atom'

#FIXME: Temporary thing for pretty output on MY screen.
if process.env.TERM_PROGRAM is 'iTerm.app' and process.env.USER is 'eddieantonio'
  pe = require('pretty-error').start()
  pe.skipNodeFiles()
  pe.skipPackage('q')
  pe.skipPath('/Applications/Atom.app/Contents/Resources/app/vendor/jasmine.js')


PredictionList = require './prediction-list'
TextFormatter = require './text-formatter'

# This class listens to editor events, forwarding state, and updating a model. In
# effect, this is kind of a View/Controller in classical MVC.
#
# It is primarily concerned with getting surrounding token context, receiving
# predictions, and forwarding display of predictions (through [INSERT CLASS
# HERE]).

module.exports =
class EditorSpy
  lastChangeWasPredictionInsert: false
  predictionMarker: null
  subscriptions: new CompositeDisposable

  # The model.
  predictionList: new PredictionList

  @content: ->
    # TODO: look-up these classes! overlay from-top
    @div class: 'gamboge hidden'

  constructor: (@predictionList, @editor) ->
    @buffer = @editor.getBuffer()

    # The insert formater needs to know how to get the current indenting
    # level...
    indentSpy = TextFormatter.makeEditorIndentSpy(@editor)
    @insertFormatter = new TextFormatter(indentSpy)

    # LISTEN TO ALL OF THE EVENTS!
    @registerEvents()

  registerEvents: ->
    # Updates the prediction model. Invoked 300ms after last buffer change.
    # TODO: use `onDidChange` instead?
    @editor.onDidStopChanging =>
      return @resetChangeIgnorance() if @lastChangeWasPredictionInsert
      @askForPredictions()

    @subscriptions.add atom.commands.add '.gamboge',
      'gamboge:show-suggestions': => @askForPredictions()
      'gamboge:complete': => @completeTokens n: 1
      'gamboge:complete-all': => @completeTokens all: yes
      'gamboge:next-prediction': => @predictionList.next()
      'gamboge:previous-prediction': => @predictionList.prev()

  completeTokens: ({n, all}) ->
    {entropy, tokens} = @predictionList.current()
    n = tokens.length if all
    insertTokens = tokens.slice(0, n)

    insertText = @insertFormatter.format insertTokens
    cursorPosition = @editor.getCursorBufferPosition()

    @ignoreNextChange()
    @editor.setTextInBufferRange([cursorPosition, cursorPosition], insertText)
    @askForPredictions()

  askForPredictions: ->
    text = @getTextForCursorContext()

    # Set off prediction request
    @predict text, (predictions) =>
      return unless predictions?
      @predictionList.setPredictions predictions

  # Using markers, shows the GhostText.
  showGhostText: (prediction) ->
    return unless prediction

    {tokens} = prediction

    # Get a marker for the place immediately adjacent the cursor.
    afterCursor = @editor.getCursorBufferPosition()

    # Oh dear...
    {row, column} = @editor.getCursorScreenPosition()

    # TODO: Check if the cursor is on screen!

    @predictionMarker = @editor.markBufferPosition afterCursor,
      invalidate: 'touch'
      persistent: no

    @predictionMarker.onDidChange (marker) =>
      unless marker.isValid
        @destroyMarker()
        @predictionList.invalidate()

  # Get rid of the prediction marker and any annotation associated with it.
  destroyMarker: ->
    @predictionMarker?.destroy()
    @predictionMarker = null

  # Next change event was our fault...
  ignoreNextChange: ->
    @lastChangeWasPredictionInsert = true

  resetChangeIgnorance: ->
    @lastChangeWasPredictionInsert = false

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

    # TODO: use grammar.name; need a look-up table for each language.
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
    @detach()

# TODO: Make a popover suggestion list ACTUALLY based on autocomplete!
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee

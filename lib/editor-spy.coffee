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

  # A reference to the model.
  predictionList: null
  # We don't need any references to any views.

  constructor: (@predictionList, @editor, @predict) ->
    unless @predict?
      @predict = require('./async-predictor').defaultPredictor

    # The insert formater needs to know how to get the current indenting
    # level...
    indentSpy = TextFormatter.makeEditorIndentSpy(@editor)
    @insertFormatter = new TextFormatter(indentSpy)

    # Listen to all of the events!
    @registerEvents()

  registerEvents: ->
    # Updates the prediction model. Invoked 300ms after last buffer change.
    @subscriptions.add @editor.onDidChange =>
      return @resetChangeIgnorance() if @lastChangeWasPredictionInsert
      @askForPredictions()

    @subscriptions.add atom.commands.add '.gamboge',
      'gamboge:show-suggestions':    => @askForPredictions()
      'gamboge:complete':            => @completeTokens n: 1
      'gamboge:complete-all':        => @completeTokens all: yes
      'gamboge:next-prediction':     => @predictionList.next()
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
    afterCursor = {row, column} = @editor.getCursorBufferPosition()
    text = @getTextForCursorContext(afterCursor)

    @predictionMarker = @editor.markBufferPosition afterCursor,
      invalidate: 'touch'
      persistent: no

    oneTimeSubscription = @predictionMarker.onDidChange (marker) =>
      unless marker.isValid
        oneTimeSubscription.dispose()
        @destroyMarker()
        @predictionList.invalidate()

    # TODO: use grammar.name; need a look-up table for each language.
    language = 'py'

    # Set off prediction request
    @predict text, language, (predictions) =>
      return unless predictions?
      @predictionList.setPredictions(predictions, [row, column])

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
  getTextForCursorContext: (cursorPosition) ->
    # Get text for the current line.
    beginningOfLine = new Point(cursorPosition.row, 0)
    contextRange = new Range(beginningOfLine, cursorPosition)

    # TODO: Get more text than just the current line.
    @editor.getTextInBufferRange(contextRange)


  # Tear down any state and detach.
  destroy: ->
    @subscriptions.dispose()
    @detach()


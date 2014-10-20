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

{Point, Range, View} = require 'atom'
_ = require 'underscore-plus'

# This class listens to editor events, forwarding state, and updating a model. In
# effect, this is kind of a View/Controller in classical MVC.
#
# It is primarily concerned with getting surrounding token context, receiving
# predictions, and forwarding display of predictions (through [INSERT CLASS
# HERE]).

# Use at most this many tokens to form predictions.
NGRAM_ORDER = 3

# Note: Heavily based on: atom/autocomplete, (C) GitHub Inc. 2014
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee
module.exports =
class GambogeView extends View
  editor: null
  buffer: null

  # TODO: Refactor Gamboge event listener from this.

  @content: ->
    # TODO: look-up these classes! overlay from-top
    @div class: 'gamboge hidden'

  initialize: (@editorView) ->
    {@editor} = @editorView
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
      # TODO Figure out change location from cursor
      rawTokens = @getTokensForCursorContext()
      tokens = GambogeView.makeMostImportantTokenList(rawTokens)

      # Set off prediction request
      @predict tokens, (predictions) =>
      # TODO: Display predictions...
        console.log GambogeView.sortPredictions predictions
        console.log "Done predictions."


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

  # Gets a list of tokens for the preceeding context of the cursor.
  # TODO: Possible refactor: get all of this token stuff into its own...
  # thing...
  getTokensForCursorContext: ->

    # TODO: Fancier token retrieving logic!
    # Get tokens for the current line
    cursorPosition = @editor.getCursorBufferPosition()
    beginningOfLine = new Point(cursorPosition.row, 0)
    contextRange = new Range(beginningOfLine, cursorPosition)

    # Even though Grammar::tokenizeLines does this for us, it always assumes
    # the first line of the input is the first line in the file.
    text = @editor.getTextInBufferRange(contextRange)
    isFirstLine = contextRange.intersectsRow(0)

    # Get the grammar to tokenize the context for us.
    {tokens} = @grammar.tokenizeLine(text, null, isFirstLine)
    tokens

  # Given tokens, returns a list of strings of tokens.
  @makeMostImportantTokenList: (tokens) ->
    nonWhitespace = []
    for token in tokens
      {value} = token
      continue unless value?
      nonWhitespace.push(value) unless value.trim() is ""

    numTokens = nonWhitespace.length
    # Get last three tokens to make a trigram
    lastThreeTokens = nonWhitespace.slice(numTokens - NGRAM_ORDER, numTokens)

  # Do the prediction, calling callback when finished.
  predict: (tokens, done) ->
    # Create the token path component, URI encoding each token.
    path = (encodeURIComponent(token) for token in tokens).join('/')

    origin = atom.config.get 'gamboge.unnaturalRESTOrigin'
    # use @grammar.name => But need a look-up table for the language...
    lang = 'py' #@grammar.langage
    url = "http://#{origin}/#{lang}/predict/#{path}"
    xhr = new XMLHttpRequest()
    xhr.open('GET', url, yes)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.addEventListener 'load', =>
      return unless xhr.status is 200
      {suggestions} = JSON.parse(xhr.responseText)
      done(suggestions)
    xhr.send()

  @sortPredictions: (predictions) ->
    # We want the longest, most probable prediction possible.
    # The problem is that shorter predictions are most probable. So! We weight
    # predictions not only based on their cross-entropy, but also how long
    # they are relative to the longest prediction.
    longestPrediction = _.max predictions, ([_entropy, tokens]) -> tokens.length
    maxPredictionLen = longestPrediction[1].length

    result = _.sortBy predictions, ([entropy, tokens]) ->
      maxPredictionLen * entropy / tokens.length

    result

  # Tear down any state and detach.
  destroy: ->
    @editorView.removeClass 'gamboge'
    @detach()

# TODO: Make a popover suggestion list ACTUALLY based on autocomplete!
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee

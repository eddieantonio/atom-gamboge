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

{View} = require 'atom'

# This class listens to editor events, forwarding state, and updating a model. In
# effect, this is kind of a View/Controller in classical MVC.
#
# It is primarily concerned with getting surrounding token context, receiving
# predictions, and forwarding display of predictions (through [INSERT CLASS
# HERE]).

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
    # TODO: Is this even required?
    #atom.workspaceView.command "gamboge:activate", => @activate()

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
      # TODO
      # Figure out change location from cursor
      rawTokens = @getTokensForCursorContext()
      trailer = @makeMostImportantTokenList(rawTokens)
      console.log {trailer}

      # Set off prediction request
      # Display predictions


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
  getTokensForCursorContext: ->
    # TODO: Return both preceeding and following tokens.
    contextRange = @editor.getCurrentParagraphBufferRange()
    text = @editor.getTextInBufferRange(contextRange)
    isFirstLine = contextRange.intersectsRow(0)

    # Get the grammar to tokenize the context for us!
    {tokens} = @grammar.tokenizeLine(text, null, isFirstLine)
    tokens

  # Given tokens, returns a list of strings of tokens.
  makeMostImportantTokenList: (tokens) ->
    numTokens = tokens.length
    # Get last three tokens to make a trigram
    lastThreeTokens = tokens.slice(numTokens - 3, numTokens)
    (token.value for token in lastThreeTokens)


  # Tear down any state and detach.
  destroy: ->
    @editorView.removeClass 'gamboge'
    @detach()

  # Probably loads all of the corpus model, thing, stuff.
  activate: ->
    # TODO: What am I even doing on activate?
    console.log "GambogeView activated!"
    """
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
    """

# TODO: Make a popover suggestion list ACTUALLY based on autocomplete!
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete-view.coffee

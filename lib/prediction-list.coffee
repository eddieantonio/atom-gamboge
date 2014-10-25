{Emitter} = require 'event-kit'
_ = require 'underscore-plus'

module.exports =
# Stores a bunch of sorted predictions. Immutable
# Keeps track of the currently active predictions
class PredictionList

  # This class is completely over-engineered, but I don't care! (I love it).
  constructor: (predictions) ->
    defp @, '_predictions', value: []
    defp @, '_index',  value: 0
    defp @, 'emitter',  value: new Emitter

    def @, 'isEmpty', get: -> @_predictions.length is 0
    def @, 'current', get: -> @_predictions[@_index]
    def @, 'index',   get: -> @_index
    def @, 'length',  get: -> @_predictions.length

    @setPredictions predictions

  next: ->
    return {reached_end: yes, value: 0} if @_index >= @_predictions.length - 1
    @_index += 1
    {reached_end: no, index: @_index}

  prev: ->
    return {reached_end: yes, value: 0} if @_index <= 0
    @_index -= 1
    {reached_end: no, index: @_index}

  setPredictions: (newPredictions) ->
    @_predictions = PredictionList.createUnderlyingArray(newPredictions)
    @emitter.emit 'did-predictions-change', @

  onDidPredictionChange: (callback) ->
    @emitter.on 'did-predictions-change', callback

  # Internal: Returns the underlying array representation.
  @createUnderlyingArray: (rawSuggestions) ->
    {predictions, max} =
      PredictionList.createPredictionArrayWithMax(rawSuggestions)

    PredictionList.sortPredictions(predictions, max)
    
  # Internal: Iterate through array once, both creating nice Prediction
  # objects for every prediction AND getting the maximum length of prediction!
  @createPredictionArrayWithMax: (rawSuggetions) ->
    max = -1
    
    predictions =
    rawSuggetions.map ([entropy, tokens]) ->
      max = tokens.length unless max > tokens.length
      #new Prediction(entropy, tokens)
      {entropy, tokens}

    {predictions, max}

  # Internal: Sorts predictions according to a ranking that prefers longer
  # suggestions.
  @sortPredictions: (predictions, maxPredictionLen)->
    # We want the longest, most probable prediction possible.
    # The problem is that shorter predictions are most probable. So! We weight
    # predictions not only based on their cross-entropy, but also how long
    # they are relative to the longest prediction.
    _.sortBy predictions, ({entropy, tokens}) ->
      maxPredictionLen * entropy / tokens.length

# Internal: Just a data class. 
do ->
  class Prediction
    constructor: (@entropy, @tokens) ->

def = (obj, prop, opts) ->
  opts.enumerable ?= yes
  opts.configurable ?= no
  Object.defineProperty obj, prop, opts

defp = (obj, prop, opts) ->
  opts.enumerable ?= no
  opts.configurable ?= yes
  Object.defineProperty obj, prop, opts

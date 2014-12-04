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

{Emitter} = require 'event-kit'
_ = require 'underscore-plus'

module.exports =
# Stores a bunch of sorted predictions. Keeps track of the currently
# active predictions.
class PredictionList
  predictions: []
  position: [0, 0]
  index: 0

  # Creates the initial prediction list.
  constructor: (predictions, bufferPosition) ->
    @emitter = new Emitter

    @setPredictions(predictions, bufferPosition) if predictions?

  # Get the next prediction.
  next: -> @changeRelative +1

  # Get the previous prediction.
  prev: -> @changeRelative -1

  # Change the index by the given value.
  changeRelative: (amount) ->
    direction = switch
      when amount is 0 then 'beginning'
      when amount > 0 then 'next'
      else 'prev'

    @index += amount

    wrapped = switch
      when @predictions.length is 0 then false
      when not (0 <= @index < @predictions.length)
        # Wrap the value around.
        @index %%= @predictions.length
        true
      else false

    status = {index: @index, direction, wrapped, target: @}

    @emitter.emit 'did-change-index', status
    status

  # Replace the predictions with a brand new set.
  setPredictions: (newPredictions, bufferPosition) ->
    @invalidate()
    @predictions = PredictionList.createUnderlyingArray(newPredictions)
    @index = 0

    # Set this AFTER we've created the underlying array, so as to not have
    # inconsistent properties. 
    @position = bufferPosition

    @emitter.emit 'did-predictions-change', @
    # Trigger the 'changed index event' with the new index 0.
    @changeRelative 0

  # Called on invalidation
  invalidate: ->
    @emitter.emit 'did-invalidate', @


  # Returns whether the predictions are empty.
  isEmpty: -> @predictions.length is 0
  # Returns the current prediction, with the current buffer position.
  current: ->
    if @predictions[@index]?
      # Create a new object with the position AND the prediction.
      _.extend({@position}, @predictions[@index])
    
  # Returns the current index in the prediction list.
  index: -> @index
  # Returns the amount of predictions.
  length: -> @predictions.length


  # Calls callback when the prediction list has changed.
  # The callback gets passed the prediction list.
  onDidChangePredictions: (callback) ->
    @emitter.on 'did-predictions-change', callback

  # Calls callback when the prediction list has been marked as
  # invalidated.
  # The callback gets passed the prediction list.
  onDidInvalidate: (callback) ->
    @emitter.on 'did-invalidate', callback

  # Calls callback when the prediction index is changed.
  # The callback gets passed a change status object.
  onDidChangeIndex: (callback) ->
    @emitter.on 'did-change-index', callback



  destroy: ->
    @emitter.dispose()


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

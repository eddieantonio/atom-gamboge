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

  # Creates the initial prediction list.
  constructor: (predictions) ->
    @_predictions = []
    @_index = 0
    @emitter = new Emitter

    @setPredictions predictions if predictions?

  # Get the next prediction.
  next: -> @changeRelative +1

  # Get the previous prediction.
  prev: -> @changeRelative -1

  # Change the index by the given value.
  changeRelative: (amount) ->
    return if amount is 0
    direction = if amount > 0 then 'next' else 'prev'

    index = @_index + amount

    unless 0 <= index < @_predictions.length
      # Wrap the value around.
      index %%= @_predictions.length
      wrap = false
    else
      wrap = true

    status = {index, direction, wrapped}

    @emitter.emit 'did-change-index', status
    status

  # Replace the predictions with a brand new set.
  setPredictions: (newPredictions) ->
    @invalidate()
    @_predictions = PredictionList.createUnderlyingArray(newPredictions)
    @_index = 0

    @emitter.emit 'did-predictions-change', @

  # Called on invalidation
  invalidate: ->
    @emitter.emit 'did-invalidate', @


  # Returns whether the predictions are empty.
  isEmpty: -> @_predictions.length is 0
  # Returns the current prediction.
  current: -> @_predictions[@_index]
  # Returns the current index in the prediction list.
  index: -> @_index
  # Returns the amount of predictions.
  length: -> @_predictions.length


  # Calls callback when the prediction list has changed.
  # The callback gets passed the prediction list.
  onDidPredictionChange: (callback) ->
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

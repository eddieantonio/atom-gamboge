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

# The prediction provider provides predictions. Asynchronously!
# It should avoid state as much as possible. In fact, this abstract class
# should hold all the state necessary: the ID, and the event emitter, which
# maintains subscriptions.

module.exports =
class PredictionProvider
  nextID: 0
  emitter: new Emitter

  # Don't need to do nothing.
  constructor: ->

  # Requests predictions
  requestPredictions: (context) ->
    id = @nextID
    @nextID += 1

    @predict id, context

  onPredictionsReady: (callback) ->
    @emitter.on 'predictions-ready', callback

  # Private stuff here!

  # To be overridden by subclasses.
  predict: -> throw new Error('Must be implemented by subclass')
  # Called when prediction succeeded
  succeeded: (id, data) ->
    data.id = id
    @emitter.emit 'predictions-ready', data
  failed: (id, reason, extra) ->
    throw new Error('Not Implemented')


# The default currently is the UnnaturalCode predictor.
Object.defineProperty PredictionProvider, 'defaultProvider',
  get: -> require('./unnaturalcode-predictor')

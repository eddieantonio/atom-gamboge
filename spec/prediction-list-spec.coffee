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

PredictionList = require '../lib/prediction-list'
_ = require 'underscore-plus'

describe 'PredictionList', ->

  describe '::constructor()', ->
    it 'constructs with zero arguments', ->
      expect(-> new PredictionList()).not.toThrow()

  describe 'after instantation', ->
    [predictionList] = []

    beforeEach ->
      predictionList = new PredictionList

    describe '::setPredictions()', ->
      it 'emits a "changed predictions" event'
      it 'emits a "change index" event'

    describe '::next()', ->
      it 'emits a "change index" event', ->
      it 'wraps around when going around the of the list', ->

    describe '::previous()', ->
      it 'emits a "change index" event'

    describe '::invalidate()', ->
      it 'emits a "predictions invalidates" event'

    describe '::current()', ->
      it 'returns undefined when the prediction list is empty', ->
        predictionList.setPredictions([])

        expect(predictionList.current()).toBeUndefined()

  describe '.createUnderlyingArray()', ->
    it 'sorts the list, biassing towards longer, but slightly less probable
        sequences', ->

      predictions = [
        [ 0.337218, [ "in", "range" ] ]
        [ 0.345281, [ "in", "range", "(" ] ]
        [ 1.85889, [ "in", "range", "(", "5" ] ]
        [ 2.08747, [ "in", "range", "(", "5", ")" ] ]
        [ 2.21087, [ "in", "range", "(", "10" ] ]
        [ 2.40771, [ "in", "range", "(", "10", ")" ] ]
      ]

      sortedPredictions = PredictionList.createUnderlyingArray predictions
      likeliestSuggestion = sortedPredictions[0]
      highlySuggestedTokens = likeliestSuggestion.tokens

      expect(highlySuggestedTokens.length).toBeGreaterThan 2
      expect(highlySuggestedTokens).toContain 'in'
      expect(highlySuggestedTokens).toContain 'range'
      expect(highlySuggestedTokens).toContain '('

      # When I say "entropy", I really mean negative log probability or
      # "surprisal" (self-information), but :/
      # See also: http://en.wikipedia.org/wiki/Self-information
      lowestOverallEntropy =
        (_.min sortedPredictions, (s) -> s.entropy).entropy
      expect(likeliestSuggestion.entropy).toBeGreaterThan lowestOverallEntropy



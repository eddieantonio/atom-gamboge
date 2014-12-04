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

_ = require 'underscore-plus'

PredictionList = require '../lib/prediction-list'
predictions = require './fixtures/predictions'

describe 'PredictionList', ->

  describe '::constructor()', ->
    it 'constructs with zero arguments', ->
      expect(-> new PredictionList()).not.toThrow()

  describe 'after instantiation', ->
    [predictionList] = []

    beforeEach ->
      predictionList = new PredictionList

    describe '::setPredictions()', ->
      it 'emits a "changed predictions" event', ->
        didChangePrediction = no
        predictionList.onDidChangePredictions ->
          didChangePrediction = yes
        runs ->
          predictionList.setPredictions predictions.ellipsis
        waitsFor (-> didChangePrediction), 1
        runs ->
          expect(predictionList.current().tokens).toEqual ['...']

      it 'emits a "change index" event', ->
        issuedEvent = no
        predictionList.onDidChangeIndex ({index, direction}) ->
          expect(index).toBe 0
          expect(direction).toBe 'beginning'
          issuedEvent = yes
        runs ->
          predictionList.setPredictions(predictions.ellipsis)
        waitsFor (-> issuedEvent), 1

    describe '::next()', ->
      it 'emits a "change index" event', ->
        issuedEvent = no
        predictionList.setPredictions(predictions.ellipsis)
        predictionList.onDidChangeIndex ({index, direction, wrapped}) ->
          expect(index).toBe 1
          expect(direction).toBe 'next'
          expect(wrapped).toBeFalsy()
          issuedEvent = yes
        runs ->
          predictionList.next()
        waitsFor (-> issuedEvent), 1

      it 'wraps around when going around the of the list', ->
        issuedEvent = no
        predictionList.setPredictions(predictions.ellipsis)

        expect(predictionList.length()).toBe 2
        # Get to the last element.
        predictionList.next()

        predictionList.onDidChangeIndex ({index, direction, wrapped}) ->
          expect(index).toBe 0
          expect(direction).toBe 'next'
          expect(wrapped).toBeTruthy()
          issuedEvent = yes
        runs ->
          predictionList.next()
        waitsFor (-> issuedEvent), 1


    describe '::previous()', ->
      it 'emits a "change index" event', ->
        issuedEvent = no
        predictionList.setPredictions(predictions.ellipsis)

        # Get to the last element.
        predictionList.next()
        predictionList.onDidChangeIndex ({index, direction, wrapped}) ->
          expect(index).toBe 0
          expect(direction).toBe 'prev'
          expect(wrapped).toBeFalsy()
          issuedEvent = yes
        runs ->
          predictionList.prev()
        waitsFor (-> issuedEvent), 1

      it 'wraps around when going around the of the list', ->
        issuedEvent = no
        predictionList.setPredictions(predictions.ellipsis)

        expect(predictionList.length()).toBe 2

        predictionList.onDidChangeIndex ({index, direction, wrapped}) ->
          expect(index).toBe 1
          expect(direction).toBe 'prev'
          expect(wrapped).toBeTruthy()
          issuedEvent = yes
        runs ->
          predictionList.prev()
        waitsFor (-> issuedEvent), 1


    describe '::invalidate()', ->
      it 'emits a "predictions invalidates" event', ->
        signaledInvalidated = no
        predictionList.setPredictions(predictions.ellipsis)

        predictionList.onDidInvalidate ->
          signaledInvalidated = yes
        runs ->
          predictionList.invalidate()
        waitsFor (-> signaledInvalidated), 1


    describe '::current()', ->
      it 'returns undefined when the prediction list is empty', ->
        predictionList.setPredictions([])

        expect(predictionList.current()).toBeUndefined()

      it 'returns the current prediction with tokens, entropy, and buffer position', ->
        arbitraryPoint = [42, 6]
        predictionList.setPredictions(predictions.ellipsis, arbitraryPoint)

        {tokens, entropy, position} = predictionList.current()
        expect(tokens).toEqual ['...']
        expect(entropy).toBeGreaterThan 0
        expect(position).toEqual [42, 6]


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



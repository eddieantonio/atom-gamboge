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

describe 'PredictionList', ->

  describe '::constructor', ->
  describe '::next', ->
    it 'can be subscribed to'
  describe '::prev', ->
    it 'can be subscribed to'
  describe '::setPredictions', ->
    it 'can be subscribed to'
  describe '::invalidate', ->
    it 'can be subscribed to'
  describe '::current', ->

  describe '.sortPredictions', ->
    it 'should bias towards longer, but slightly less probable sequences', ->
      predictions = [
        [ 0.337218, [ "in", "range" ] ]
        [ 0.345281, [ "in", "range", "(" ] ]
        [ 1.85889, [ "in", "range", "(", "5" ] ]
        [ 2.08747, [ "in", "range", "(", "5", ")" ] ]
        [ 2.21087, [ "in", "range", "(", "10" ] ]
        [ 2.40771, [ "in", "range", "(", "10", ")" ] ]
      ]

      sortedPredictions = GambogeView.sortPredictions predictions
      mostProbableTokens = sortedPredictions[0][1]
      expect(mostProbableTokens.length).toBeGreaterThan 2
      expect(mostProbableTokens).toContain 'in'
      expect(mostProbableTokens).toContain 'range'
      expect(mostProbableTokens).toContain '('

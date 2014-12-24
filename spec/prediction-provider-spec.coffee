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

PredictionProvider = require '../lib/prediction-provider'
predictions = require './fixtures/predictions'

describe "PredictionProvider", ->
  # TODO: EVERYTHING!
  describe '::constructor', ->
  describe '::requestPrediction', ->
  describe 'when a prediction is ready', ->
  describe '.defaultProvider', ->
    it 'returns the UnnaturalCode provider', ->
      UnnaturalCodeProvider =
        require '../lib/prediction-provider/unnaturalcode-predictor'
      expect(PredictionProvider.defaultProvider).toBe UnnaturalCodeProvider

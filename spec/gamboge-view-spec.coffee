GambogeView = require '../lib/gamboge-view'

describe "GambogeView", ->

  describe 'sortPredictions method that I should refactor out of this class', ->
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

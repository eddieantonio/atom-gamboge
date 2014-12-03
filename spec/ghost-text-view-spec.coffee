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


# SO.... there are a lot of problems with these specs. Like how they mostly
# don't exist. And how Atom doesn't currently update the EditorView on editor
# events.

{WorkspaceView} = require 'atom'
{$} = require 'space-pen'

HackyGhostView = require '../lib/hacky-ghost-text-view'
PredictionList = require '../lib/prediction-list'
predictions = require './fixtures/predictions.coffee'

# FIXME:
fdescribe "HackyGhostView", ->
  [editor, $editor, ghostView, pList] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    pList = new PredictionList

    waitsForPromise ->
      atom.workspace.open('sample.py')

    runs ->
      atom.workspaceView.simulateDomAttachment()
      $editor = atom.workspaceView.getActiveView()
      editor = $editor.getModel()

  describe '::constructor()', ->
    it 'subscribes to PredictionList events', ->
      spyOn(pList, 'onDidChangePredictions')

      new HackyGhostView(pList, $editor)

      expect(pList.onDidChangePredictions).toHaveBeenCalled()


  describe '::setAt()', ->
    [prediction] = []
    beforeEach ->
      ghostView = new HackyGhostView(pList, $editor)
      [prediction] = PredictionList.createUnderlyingArray(
        predictions['after for i in range(10):']
      )

    xit 'displays ghost text at the end of the line', ->
      editor.setText('for i in range(10):')

      ghostView.setAt(prediction.tokens, [1, 19])

      selector = '.gamboge-ghost, .gamboge-invisible'
      expect($editor).toContain(selector)
      expect($editor.find(selector)).not.toBeEmpty()

    # Not implemented: v0.2.0-prerelease.
    xit 'displays ghost text in the middle of the line', ->
      editor.setText('for i in range(10):')

      # After for i/...
      ghostView.setAt(prediction.tokens, [1, 5])

      selector = '.gamboge-ghost, .gamboge-invisible'
      expect($editor).toContain(selector)
      expect($editor.find(selector)).not.toBeEmpty()

    # TODO: should ghost-view set this, or should editor-spy?
    it 'sets the .gamboge class on the editor', ->
      expect($editor).not.toMatchSelector '.gamboge'

      ghostView.setAt(prediction.tokens, [1, 19])
      expect($editor).toMatchSelector '.gamboge'


  describe '::removeAll()', ->
    beforeEach ->
      pList.setPredictions predictions.ellipsis
      ghostView = new HackyGhostView(pList, $editor)
      ghostView.setAt(pList.current().tokens, [0,0])

    #FIXME
    xit 'removes all gamboge-ghost spans and any prediction text from the editor', ->
      # Set the prediction.
      expect($editor).toContain '.gamboge-ghost'

      ghostView.removeAll()
      expect($editor).not.toContain '.gamboge-ghost'
      expect($editor).not.toContain '.gamboge-invisible'

    it 'removes the `gamboge` class from the editor', ->
      expect($editor).toHaveClass 'gamboge'

      ghostView.removeAll()
      expect($editor).not.toHaveClass 'gamboge'

  # These ALL need to be written.
  xdescribe 'when PredictionList triggers an event', ->
    beforeEach ->
      ghostView = new HackyGhostView(pList, $editor)

    describe 'when a prediction is active', ->
      # TODO: set a prediction with tokens and whitespace.

      it 'wraps whitespace with span of class `gamboge-invisible`', ->
        expect($editor).toContain('.gamboge-invisible')

      it 'inserts the correct visible whitespace tokens'
      # TODO: check config values.

      it 'adds the `gamboge` class to the editor'

    describe 'when the PredictionList changes', ->
      it 'displays the current prediction'
      it 'keeps the `gamboge` class on the editor'

    describe 'when the prediction is deactived', ->
      it 'removes the `gamboge` class'


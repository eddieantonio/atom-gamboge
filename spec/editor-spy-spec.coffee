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

EditorSpy = require '../lib/editor-spy'
TextEditorView = require 'atom'

describe "EditorSpy", ->
  [predictionList, editor] = []

  beforeEach ->
    atom.workspaceView = workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    runs ->
      predictionList = new PredictionList
      editor = (new TextEditorView).getModel()
      atom.workspaceView.simulateDomAttachment()

  describe '::constructor()', ->
    describe 'event subscription', ->
      beforeEach ->

      it 'subscribes to PredictionList change prediction events', ->
        spyOn predictionList, 'onChangePrediction'
        new EditorSpy(predictionList, editor)
        expect(predictionList.onChangePrediction).toHaveBeenCalled()

      it 'subscribes to TextEditor events', ->
        spyOn editor, 'onDidChange'
        spyOn editor, 'onStopChanging'

        expect(editor.onDidChange.length or editor.onStopChanging.length).toBe 1

  describe 'when gamboge:next-prediction is triggered', ->
    it 'acknowledges next prediction requests', ->

  describe 'when gamboge:previous-prediction is triggered', ->
    it 'acknowledges previous prediction requests'

  describe 'when gamboge:complete is triggered', ->
    it 'inserts the first of the current prediction'

  describe 'when gamboge:complete-all is triggered', ->
    it 'inserts every token of the current prediction when asked'

  describe 'interaction with PredictionList', ->
    it 'listens to changes in text predictions'
    it 'inserts text when prompted'
    it 'invalidates the current preidction when the buffer is changed'
    it 'notifies its PredictionList of cursor events in the editor'


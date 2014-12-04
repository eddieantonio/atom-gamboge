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

{TextEditor, WorkspaceView} = require 'atom'
{$} = require 'space-pen'

EditorSpy = require '../lib/editor-spy'
HackyGhostView = require '../lib/hacky-ghost-text-view'
PredictionList = require '../lib/prediction-list'

predictions = require './fixtures/predictions'

describe "EditorSpy", ->
  [predictionList, editor, editorSpy, $editor] = []

  beforeEach ->
    runs ->
      # Bunch of boilerplate test code...
      atom.workspaceView = new WorkspaceView()
      atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.workspace.open('sample.js').then (e) ->
        editor = e
        atom.workspaceView.attachToDom()
        $editor = $(atom.views.getView(editor))
        editor.setText('')

    runs ->
      predictionList = new PredictionList

  trigger = (event) ->
    atom.commands.dispatch($editor.get(0), event)

  describe '::constructor()', ->
    describe 'event subscription', ->
      it 'subscribes to TextEditor events', ->
        spyOn(editor, 'onDidChange')
        spyOn(editor, 'onDidStopChanging')

        new EditorSpy(predictionList, editor)

        expect(editor.onDidStopChanging.calls.length or
          editor.onDidChange.calls.length).toBeGreaterThan 0

  describe 'Editor events', ->
    beforeEach ->
      editorSpy = new EditorSpy(predictionList, editor)
      predictionList.setPredictions predictions['start of file']

    describe 'when gamboge:next-prediction is triggered', ->
      it 'does nothing [without .gamboge]', ->
        expect($editor).not.toHaveClass 'gamboge'
        spyOn(predictionList, 'next')
        trigger('gamboge:next-prediction')
        expect(predictionList.next).not.toHaveBeenCalled()

      it 'acknowledges next prediction requests [with .gamboge]', ->
        $editor.addClass('gamboge')
        spyOn(predictionList, 'next')
        trigger('gamboge:next-prediction')
        expect(predictionList.next).toHaveBeenCalled()

    describe 'when gamboge:previous-prediction is triggered', ->
      it 'acknowledges previous prediction requests [with gamboge]', ->
        $editor.addClass('gamboge')
        spyOn(predictionList, 'prev')
        trigger('gamboge:previous-prediction')
        expect(predictionList.prev).toHaveBeenCalled()

      it 'does nothing [without gamboge]', ->
        expect($editor).not.toHaveClass 'gamboge'
        spyOn(predictionList, 'prev')
        trigger('gamboge:previous-prediction')
        expect(predictionList.prev).not.toHaveBeenCalled()

    describe 'when gamboge:complete is triggered', ->
      it 'inserts the first token of the current prediction', ->
        $editor.addClass('gamboge')
        expect(editor.getText()).toBe ''

        trigger('gamboge:complete')
        expect(editor.getText()).toBe 'import '

      # TODO: test :not(.gamboge)

    describe 'when gamboge:complete-all is triggered', ->
      it 'inserts every token of the current prediction when asked', ->
        $editor.addClass('gamboge')
        expect(editor.getText()).toBe ''

        trigger('gamboge:complete-all')
        expect(editor.getText()).toBe 'import os \n'

      # TODO: test :not(.gamboge)

  describe 'interaction with PredictionList', ->
    beforeEach ->
      editor.setText('')
    xit 'invalidates the current prediction when the buffer is changed', ->
      spyOn(predictionList, 'setPredictions').andCallThrough()

      # NOTE: This test knows *waaaaaay* too much about the inner workings of
      # the class.
      originalPredictions = predictions['start of file']

      # A prediction should be active.
      predictionList.setPredictions originalPredictions, [0, 0]

      # Now create the editor spy...
      editorSpy = new EditorSpy(predictionList, editor)

      newPredictions = predictions['after for i in']
      typedText = 'for i in'

      # When the editor calls its predict method, intercept it with our own
      # "HTTP request".
      jasmine.createSpy(editorSpy, 'predict').andCallFake (text, done) ->
        expect(text).toBe typedText
        done(newPredictions)

      stoppedChanging = no
      editor.onDidStopChanging ->
        stoppedChange = yes
      waitsFor((-> stoppedChanging), 301)

      # This will trigger a change event.
      editor.insertText(typedText)

      setTimeout(->
        expect(predictionList.invalidate).toHaveBeenCalled()
      , 1000)

      expect(editor.getText()).toBe typedText

    xit 'notifies its PredictionList of cursor events in the editor', ->
      # Get the test setup.
      editor.setText('for i in')
      spyOn(predictionList, 'invalidate').andCallThrough()

      editorSpy = new EditorSpy(predictionList, editor)

      # An arbitrary move.
      editor.moveToBeginningOfWord()
      expect(predictionList.invalidate).toHaveBeenCalled()


{$} = require 'space-pen'
HackyGhostView = require '../lib/hacky-ghost-view'

describe "HackyGhostView", ->
  [$editor, ghostView] = []

  beforeEach ->
    atom.workspaceView = workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('gamboge')

    runs ->
      atom.workspaceView.simulateDomAttachment()
      $editor = atom.getActiveTextEditor().getView()
      ghostView = new HackyGhostView($($editor))


  describe '::constructor()', ->
    it 'subscribes to PredictionList cursor events'
    it 'subscribes to TextEditor events'

  describe 'interaction with PredictionList', ->
    it 'displays the current prediction when the prediction is changed'
    it 'adds the `gamboge` class to the editor when a prediction is active'
    it 'removes the `gamboge` class when no prediction is active'
    it 'inserts the correct amount of whitespace for tokens'
    it 'wraps whitespace with span of class `gamboge-whitespace`'

  describe '::setAt()', ->
    it 'displays ghost text at the end of the line'
    it 'displays ghost text in the middle of the line'

  describe '::removeAll()', ->
    beforeEach ->
      $editor.addClass 'gamboge'
    it 'removes all ghost-view spans and any prediction text from the editor'
    it 'removes the `gamboge` class from the editor', ->
      ghostView.removeAll()
      expect($editor.hasClass 'gamboge').toBe false


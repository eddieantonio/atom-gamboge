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

{$} = require 'space-pen'
HackyGhostView = require '../lib/hacky-ghost-text-view'

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
    [pList] = []
    beforeEach ->
      pList = new PredictionList

    it 'subscribes to PredictionList events', ->
      spyOn pList, 'onDidChangePredictions'

  describe '::setAt()', ->
    it 'displays ghost text at the end of the line'
    # Not implemented
    it 'displays ghost text in the middle of the line'

  describe '::removeAll()', ->
    beforeEach ->
      $editor.addClass 'gamboge'

    it 'removes all ghost-view spans and any prediction text from the editor'
    it 'removes the `gamboge` class from the editor', ->
      ghostView.removeAll()
      expect($editor.hasClass 'gamboge').toBe false

  describe 'when a prediction is active', ->
    it 'wraps whitespace with span of class `gamboge-whitespace`'
    it 'inserts the correct visible whitespace tokens'
    # Do tests for special characters!
    it 'adds the `gamboge` class to the editor'
  describe 'when the PredictionList changes', ->
    it 'displays the current prediction', ->
    it 'keeps the `gamboge` class on the editor'
  describe 'when the prediction is deactived', ->
    it 'removes the `gamboge` class'


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

GambogeView = require '../lib/gamboge-view'

describe "EditorSpy", ->

  beforeEach ->
    atom.workspaceView = workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    waitsForPromise ->
      atom.packages.activatePackage('gamboge')

    runs ->
      atom.workspaceView.simulateDomAttachment()


  describe '::constructor()', ->
    describe 'event subscription', ->
      it 'subscribes to PredictionList cursor events'
      it 'subscribes to TextEditor events'

  describe 'when gamboge:next-prediction is triggered', ->
    it 'acknowledges next prediction requests'
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

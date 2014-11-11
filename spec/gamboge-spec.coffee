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

{WorkspaceView} = require 'atom'

describe "Gamboge", ->
  [workspaceView] = []

  beforeEach ->
    atom.workspaceView = workspaceView = new WorkspaceView
    atom.workspaceView.attachToDom()

    runs ->
      atom.workspaceView.simulateDomAttachment()


  describe '::activate()', ->
    it 'listens to all editor events.', ->
      waitsForPromise ->
        atom.packages.activatePackage('gamboge')

  describe 'upon activation', ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('gamboge')

    describe 'when an editor is created', ->
      it 'binds the appropriate objects to it.'

    describe 'when an editor is destroyed', ->
      it 'cleans up all subscriptions associated with it'

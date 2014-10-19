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
#Gamboge = require '../lib/gamboge'

describe "Gamboge", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('gamboge')

  describe "when the gamboge:suggest event is triggered", ->
    it "shows the completion panel"
      atom.workspaceView.trigger 'gamboge:suggest'

  describe "when the gamboge:show-ghost-text is triggered", ->
    it 'should add ghost text to the editor'
  describe "when the gamboge:complete is triggered", ->
    it 'should add the first ghost-text token to the buffer'
  describe "when the gamboge:complete-all is triggered", ->
    it 'should add *all* of the ghost-text tokens to the buffer'

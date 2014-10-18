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
Gamboge = require '../lib/gamboge'

describe "Gamboge", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('gamboge')

  describe "when the gamboge:suggest event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.gamboge')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'gamboge:activate'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.gamboge')).toExist()
        atom.workspaceView.trigger 'gamboge:show-suggestions'
        expect(atom.workspaceView.find('.gamboge')).not.toExist()


  describe "when the gamboge:show-ghost-text is triggered"
  describe "when the gamboge:complete is triggered"
  describe "when the gamboge:complete-all is triggered"

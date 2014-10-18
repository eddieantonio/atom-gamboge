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

{View} = require 'atom'

module.exports =
class GambogeView extends View
  @content: ->
    # TODO: look-up these classes!
    @div class: 'gamboge overlay from-top', =>
      @div "The Gamboge package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "gamboge:activate", => @activate()

  # Returns an object that can be retrieved when package is activated
  # TODO: Do we need this?
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  # Probably loads all of the corpus model, thing, stuff.
  toggle: ->
    console.log "GambogeView activated!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

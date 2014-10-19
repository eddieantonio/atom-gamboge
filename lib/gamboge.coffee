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

GambogeView = require './gamboge-view'

# Note: this code heavily based on atom/autocomplete, (C) GitHub Inc. 2014 
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete.coffee
module.exports =

  config:
    unnaturalRESTOrigin:
      type: 'string'
      default: 'localhost:5000'
    # TODO: Should I rip-off Autocomplete+ like this?
    enableAutoActivation:
      type: 'boolean'
      default: yes
    autoActivationDelay:
      type: 'integer'
      min: 0
      default: 100


  editorSubcription: null
  # TODO: List of gamboge event listeners?


  activate: ->
    console.log 'Activating Gamboge...'
    # Activate on each editor.
    # TODO: use `atom.workspace.observeTextEditors(cb)` instead?
    @editorSubcription = atom.workspaceView.eachEditorView (editor) =>
      # TODO: Dunno exactly what any of these mean...
      if editor.attached and not editor.mini
        gambogeView = new GambogeView(editor)
        editor.on 'editor:will-be-removed', =>
          # Clean up the event dispatcher.
          gambogeView.remove()

  deactivate: ->
    @editorSubcription?.off()
    @editorSubcription = null
    @gambogeView.destroy()

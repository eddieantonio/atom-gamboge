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

# Note: this code heavily based on atom/autocomplete, (C) GitHub Inc. 2014 
# https://github.com/atom/autocomplete/blob/master/lib/autocomplete.coffee
module.exports =

  config: require('./config')

  editorSubcription: null

  activate: ->
    GambogeView = require './gamboge-view'

    console.log 'Activating Gamboge...'
    # Activate on each editor.
    @editorSubcription = atom.workspace.observeTextEditors (editor) =>
      return if editor.mini
      gambogeView = new GambogeView(editor)
      editor.onDidDestroy =>
        # Clean up the event dispatcher.
        gambogeView.remove()

  # TODO: According to the
  # [docs](https://atom.io/docs/latest/creating-a-package#source-code)
  # deactivate is fine as long as you're not doing things to external files.
  deactivate: ->
    @editorSubcription?.dispose()
    @editorSubcription = null

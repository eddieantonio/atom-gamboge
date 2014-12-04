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

  subscriptions: null

  activate: ->
    console.log '[Gamboge]: Activating'

    {CompositeDisposable} = require('event-kit')
    PredictionList = require('./prediction-list')
    HackyGhostView = require('./hacky-ghost-text-view')
    EditorSpy = require('./editor-spy')

    console.assert not @subscriptions?
    @subscriptions = new CompositeDisposable

    # Activate on each editor.
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      console.log '[Gamboge]: new editor'
      editorView = atom.views.getView(editor)

      # Instantiate all the MVC doohickeys.
      predictions = new PredictionList
      view = new HackyGhostView(predictions, editorView)
      controller = new EditorSpy(predictions, editor)

      @subscriptions.add editor.onDidDestroy =>
        @deactivateEditor(editor, controller, view)

  deactivateEditor: (editor, controller, view) ->
    console.log '[Gamboge]: deacivating editor'
    view.removeAll()
    controller.destroy()

  # Disposes of all subscriptions.
  deactivate: ->
    console.log '[Gamboge]: deactivating...'
    @subscriptions?.dispose()
    @subscriptions = null

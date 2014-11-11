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

fs = require 'fs'

{$} = require 'space-pen'
PythonShell = require 'python-shell'
keyvent = require './keyvent'

# Load the tokens from the sample commited.
fileTokens = require './sample'

module.exports =

  # Internal: Run test function on each file, saving the results as json to
  # `results/{name}.json`.
  #
  # * `name` {String} of the package under test.
  # * `fn`   {Function} that should return an object with two keys:
  #     * `keystrokes` {Integer} of how many keystokes it takes to input the
  #                     file.
  #     * `text`       {String} of the generated output.
  #
  testEnvironment: (name, fn) ->

    @editor =
       atom.workspaceView.getActiveView().getEditor()

    expect(@editor).toBeTruthy()
    files =
      [fileTokens].map (canonicalTokens) ->
        # Empty the text editor...
        @editor.setText ''

        # TODO: allow for async/callback for fn.
        answer = fn.call(@, canonicalTokens)

        text = @editor.getText()
        console.log text

        # The verification process is:
        #
        # normalized := file | tokenizer
        # expect that (normalized | typer | tokenizer) === normalized
        tokens = null
        runs ->
          tokenize text, (err, result) ->
            expect(err).toBeFalsy()
            tokens = result

        waitsFor((-> tokens?), 'Expected Python script to terminate.', 500)

        runs ->
          expect(tokens).toEqual(canonicalTokens)

    fs.writeFile "results/#{name}.json", JSON.stringify({name, files}), (err) ->
      console.warn "Could not save results for #{name}!" if err?

  # Internal: Given a workspaceView, returns a function that will type in its
  # hidden text box, as if the user were typing themselves!
  #
  # * `name` {String} of the package under test.
  # * `fn`   {Function} that should return an object with two keys:
  #     * `keystrokes` {Integer} of how many keystokes it takes to input the
  #                     file.
  #     * `text`       {String} of the generated output.
  #
  keyTyper: ($view) ->
    $inp = $view.find('input.hidden-input')
    expect($inp.length).toBe 1

    element = $inp.get(0)
    context = keyvent.on(element)

    (key) ->
      # Delegate to keyvent.js
      context.down(key)

    ###
    (key) ->
      event = new jQuery.Event('keydown', bubbles: true)
      event.keyPress = event.which = key.charCodeAt(0)
      $inp.trigger(event)
      event
    ###


tokenize = (text, done) ->
  PythonShell.defaultOptions =
    scriptPath: './spec/evaluate-helper/'

  shell = new PythonShell("json-tokenize.py", mode: 'text')

  result = ''
  shell.stdout.on 'data', (message) ->
    result += '' + message

  shell.send(text).end (err) ->
    if err? then done(err)
    else done(err, JSON.parse(result))


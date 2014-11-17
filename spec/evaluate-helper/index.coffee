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

# Load the tokens from the sample commited.
sampleTokens = require './sample'

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
    files = []
    tokenizedFiles = [sampleTokens]

    @editor =
      atom.workspaceView.getActiveView().getEditor()

    expect(@editor).toBeTruthy()
    tokenizedFiles.forEach (canonicalTokens) ->
      # Empty the text editor...
      @editor.setText ''

      # TODO: allow for async/callback for fn.
      {keystrokes} = fn.call(@, canonicalTokens)

      # XXX: Uh.... get rid of a newline at the end...
      @editor.backspace()
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
        util = require 'util'
        diff =  require('deep-diff').diff(canonicalTokens, tokens)
        console.log(util.inspect(diff, depth: null)) if diff
        expect(tokens).toEqual(canonicalTokens)

        # TODO: Probably should put the file name, just for funsies.
        files.push({keystrokes})

    waitsFor((->files.length == tokenizedFiles.length), '???', 2**24)

    runs ->
      contents = JSON.stringify({name, files})
      fs.writeFile "results/#{name}.json", contents, (err) ->
        console.warn "Could not save results for #{name}!" if err?

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


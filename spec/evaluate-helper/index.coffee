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

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#
#                      MUST BE RUN FROM REPOSITORY ROOT!                       #
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#

fs = require 'fs'

{$} = require 'space-pen'
PythonShell = require 'python-shell'

# Load the tokens from the sample commited.
tokenizedFiles = require './tokens'

SHOULD_VERIFY = not process.env.NO_VERIFY

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

    @editor =
      atom.workspaceView.getActiveView().getEditor()

    expect(@editor).toBeTruthy()
    tokenizedFiles.forEach ({tokens, filename}) ->
      canonicalTokens = tokens
      # Empty the text editor...
      @editor.setText ''

      # TODO: This should also collect prediction-by-prediction stats.
      {keystrokes} = fn.call(@, canonicalTokens)

      # XXX: Uh.... get rid of a newline at the end...
      @editor.backspace()
      text = @editor.getText()

      # The verification process is:
      #
      # normalized := file | tokenizer
      # expect that (normalized | typer | tokenizer) is normalized
      tokens = null
      runs ->
        tokenize text, (err, result) ->
          expect(err).toBeFalsy()
          tokens = result

      waitsFor((-> tokens?), 'Expected Python script to terminate.', 500)

      # Continue to the next file if we should verify.
      return unless SHOULD_VERIFY
      runs ->
        util = require 'util'
        diff =  require('deep-diff').diff(canonicalTokens, tokens)
        console.log(util.inspect(diff, depth: null)) if diff
        expect(tokens).toEqual(canonicalTokens)

        files.push({filename, keystrokes})

    waitsFor((->files.length == tokenizedFiles.length), '???', 2**24)

    runs ->
      contents = JSON.stringify({name, files})
      fs.writeFile "results/#{name}-#{now()}.json", contents, (err) ->
        console.warn "Could not save results for #{name}!" if err?

# Internal: Invokes an external Python process to tokenize the given string.
#
# Returns {Object} Python Tokens
tokenize = (text, done) ->
  PythonShell.defaultOptions =
    scriptPath: './evaluation_utils/'

  shell = new PythonShell("json_tokenizer.py", mode: 'text')

  result = ''
  shell.stdout.on 'data', (message) ->
    result += '' + message

  shell.send(text).end (err) ->
    if err? then done(err)
    else done(err, JSON.parse(result))


# Internal: Returns a {String} of the current UNIX timestamp
now = () ->
  "" + new Date().getTime()

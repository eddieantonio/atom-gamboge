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
# XXX: haha, lol
SHOULD_VERIFY = no


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
    filesDone = 0

    @editor =
      atom.workspaceView.getActiveView().getEditor()

    expect(@editor).toBeTruthy()
    tokenizedFiles.forEach ({tokens, filename}) ->
      # Empty the text editor...
      @editor.setText ''

      # XXX: Type 0..(tokens.length-350) tokens of the file.
      if name.match('gamboge')
        tokensLeft = typeMostOfTheFile(tokens)
      else
        tokensLeft = tokens

      info = null

      # Ran AFTER typing....
      finalize = =>
        # XXX: Uh.... get rid of a newline at the end...
        @editor.backspace()
        text = @editor.getText()

        info.filename = filename
        info.count = tokens.length

        verify(text, tokens) if SHOULD_VERIFY

        # Save the contents...
        contents = JSON.stringify(info)
        # XXX: We also have to the get the right pwd because it doesn't...?
        {PWD} = process.env
        fs.writeFileSync("#{PWD}/results/#{name}-#{now()}.json", contents, {flag: 'w'})
        filesDone++
        process.stderr.write "\x1b[46m#{name} typed \x1b[1m#{filename}\x1b[m\n"

      if fn.length == 2
        # Async call
        done = false
        fn.call @, tokensLeft, (result) ->
          info = result
          done = true
        waitsFor((->done), 'typer did not finish promptly', 15 * 60 * 1000)
        runs ->
          finalize()
      else
        info = fn.call(@, tokensLeft)
        finalize()


    waitsFor((->filesDone == tokenizedFiles.length), '???', 2**24)
    runs ->
      # ¯(°_o)/¯
      console.log('Done all files!')

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

# Internal: Runs an assertion to verify that the file is equivilent to its
# canonical form.
#
# The verification process is:
#
#     normalized := file | tokenizer
#     expect that (normalized | typer | tokenizer) is normalized
verify = (text, canonicalTokens) ->
  tokens = null
  runs ->
    console.log "Verifying #{canonicalTokens.length} tokens..."
    tokenize text, (err, result) ->
      expect(err).toBeFalsy()
      tokens = result
  waitsFor((-> tokens?), 'Expected Python script to terminate.', 500)

  runs ->
    util = require 'util'
    diff =  require('deep-diff').diff(canonicalTokens, tokens)
    console.warn(util.inspect(diff, depth: null)) if diff
    expect(tokens).toEqual(canonicalTokens)

# Internal: Types most of the file except for suffixLength tokens.
typeMostOfTheFile = (tokens, suffixLength=350) ->
  typer = require('../../typers/plain-text')

  length = tokens.length - suffixLength

  # If there aren't enough tokens to type, just return them.
  if length < 0
    console.log "File (#{tokens.length}) is less than
                 #{suffixLength} tokens long."
    return tokens

  [prefix, tokensLeftOver] = [tokens.slice(0, length), tokens.slice(length)]

  console.log "Typing #{prefix.length}/#{tokens.length} tokens;
               #{tokensLeftOver.length} left to type."

  PLIST?.disableNotifications()
  typer(prefix)
  PLIST?.enableNotifications()

  tokensLeftOver

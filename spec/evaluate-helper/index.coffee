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

fileTokens = [
  {text: 'for'   , cat: 'for'}
  {text: 'i'     , cat: 'NAME'}
  {text: 'in'    , cat: 'in'}
  {text: 'range' , cat: 'NAME'}
  {text: '('     , cat: '('}
  {text: '10'    , cat: 'NUMBER'}
  {text: ')'     , cat: ')'}
  {text: ':'     , cat: ':'}
  {text: '\n'    , cat: '<NEWLINE>'}
  {text: '     ' , cat: '<INDENT>'}
  {text: 'pass'  , cat: 'pass'}
  {text: ''      , cat: 'DEDENT'}
]


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

    files =
      [fileTokens].map (tokens) ->
        # TODO: allow for async/callback for fn.
        answer = fn(tokens)
        expect(answer.keystrokes).toBeGreaterThan 0
        # TODO: Make this file match tokenized results!

        # The process should be:
        #
        # normalized := file | tokenizer
        # expect that (normalized | typer | .text | tokenizer) === normalized
        # TODO: Write simple Python tokenizer script that returns results in
        # JSON.

    fs.writeFile "results/#{name}.json", JSON.stringify({name, files}), (err) ->
      console.warn "Could not save results for #{name}!" if err?

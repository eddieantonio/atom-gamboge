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

currentEnv = undefined
envs = []

module.exports =
  forEachTestFile: (fn) ->
    console.assert currentEnv?

    [fileTokens].forEach (tokens) ->
      # TODO: allow for async/callback for fn.
      answer = fn tokens
      console.log "#{currentEnv} = #{answer.keystrokes}"
      # TODO: Make this file match tokenized results!
      expect(answer).toBeGreaterThan 0

    currentEnv = undefined

  setTestEnvironment: (name) ->
    currentEnv = name
    envs[name] ?= []

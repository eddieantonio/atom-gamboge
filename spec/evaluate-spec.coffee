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


# Empirical Evaluation

{testEnvironment} = require './evaluate-helper'

# Methodology

describe "The empirical evaluation", ->
  [workspaceView] = []

  ## Setup

  beforeEach ->
    # Need the Atom editor to initialize before doing the thing...
    {WorkspaceView} = require 'atom'
    workspaceView = atom.workspaceView = new WorkspaceView
    workspaceView.attachToDom()

    # And we need Gamboge to start-up beforehand...
    waitsForPromise ->
      atom.packages.activatePackage('gamboge')

    runs ->
      workspaceView.simulateDomAttachment()

  ## Tests

  # Evaluation 1:
  #
  #  * write a file

  it "tests standard Atom text", ->
    testEnvironment 'plain-text', (tokens) ->
      count = 0
      for token in tokens
        count += switch
          when token.cat is '<INDENT>' then 0
          when token.cat is 'DEDENT' then 1
          else token.text.length

      keystrokes: count
      test: ""

  it "tests AutoComplete", ->
    testEnvironment 'autocomplete', (tokens) ->
      keystrokes: -1
  it "tests AutoComplete+", ->
    testEnvironment 'autocomplete-plus', (tokens) ->
  it "tests Gamboge", ->
    testEnvironment 'gamboge', (tokens) ->
  it "tests AutoComplete+Gamboge"

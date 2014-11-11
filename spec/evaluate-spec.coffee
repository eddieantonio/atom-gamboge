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

{WorkspaceView} = require 'atom'
{testEnvironment, keyTyper} = require './evaluate-helper'

# Methodology

fdescribe "The empirical evaluation", ->
  [editor, typeKey] = []

  ## Setup

  beforeEach ->
    # Need the Atom editor to initialize before doing the thing...
    workspaceView = atom.workspaceView = new WorkspaceView
    workspace = atom.workspace = workspaceView.getModel()
    workspaceView.attachToDom()

    waitsForPromise -> atom.workspace.open('sample.py').then (e) ->
      editor = e
      workspaceView.simulateDomAttachment()

    # And we need Gamboge to start-up beforehand...
    waitsForPromise ->
      atom.packages.activatePackage('gamboge')

    runs ->
      typeKey = keyTyper(workspaceView)

  ## Tests

  # Evaluation 1:
  #
  #  * write a file with only indent assistance.

  it "tests unassisted typing in Atom", ->
    testEnvironment 'plain-text', editor, (tokens) ->
      count = 0
      indent = ''
      file = ''
      for token in tokens
        count += switch token.category
          when 'INDENT'
            # Auto-indent means no keypress.
            0
          when 'DEDENT'
            typeKey 'backspace'
            1
          when 'NEWLINE', 'NL'
            typeKey 'enter'
            1
          else
            {text} = token
            typeKey(text.charAt(i)) for i in [0...text.length]
            typeKey 'space'
            token.text.length

      keystrokes: count


  # Evaluation 2:
  #
  #  * write a file using "best guess" autocomplete+
  it "tests AutoComplete+"

  # Evaluation 3:
  #
  #  * Write a file using Gamboge.
  it "tests Gamboge"
  it "tests AutoComplete+Gamboge"
  it "tests AutoComplete"


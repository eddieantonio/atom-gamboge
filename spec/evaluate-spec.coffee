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

fdescribe "The empirical evaluation", ->
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
  #  * write a file with only indent assistance.

  it "tests unassisted typing in Atom", ->
    testEnvironment 'plain-text', (tokens) ->
      count = 0
      indent = ''
      file = ''
      for token in tokens
        count += switch token.category
          when 'INDENT'
            indent = "    #{indent}"
            0
          when 'DEDENT'
            indent = indent.substr(4)
            1
          when 'NEWLINE', 'NL'
            file = "#{file}\n#{indent}"
            1
          else
            console.log "[#{token.category}]: #{token.text}]"
            file = if file then "#{file} #{token.text}" else token.text
            token.text.length

      keystrokes: count
      text: file


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

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
  [editorView, typeKey] = []

  ## Setup
  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.workspace.open('sample.py')

    # Need this for indentation!
    waitsForPromise ->
      atom.packages.activatePackage('language-python')

    runs ->
      atom.config.set('editor.autoIndent', true)
      atom.workspaceView.simulateDomAttachment()

  ## Tests

  # Evaluation 1:
  #
  #  * write a file with only indent assistance.

  describe 'Atom', ->
    it "tests unassisted typing in Atom", ->
      testEnvironment 'plain-text', (tokens) ->
        count = 0
        indent = ''
        file = ''
        expect(@editor.getTabText().length).toBeGreaterThan 0
        for token in tokens
          count += switch token.category
            when 'INDENT'
              # Auto-indent means no key press.
              0
            when 'DEDENT'
              @editor.backspace()
              1
            when 'NEWLINE', 'NL'
              @editor.insertNewlineBelow()
              1
            when 'ENDMARKER'
              0
            else
              @editor.insertText token.text
              @editor.insertText ' '
              token.text.length

        keystrokes: count

  # Evaluation 2:
  #
  #  * write a file using "best guess" autocomplete+
  describe 'AutoComplete+', ->
    it "tests AutoComplete+"

  # Evaluation 3:
  #
  #  * Write a file using Gamboge.
  describe 'Gamboge', ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage('gamboge')
      runs ->

    it "tests Gamboge"
  
  describe 'Optional Tests', ->
    it "tests AutoComplete+Gamboge"
    it "tests AutoComplete"


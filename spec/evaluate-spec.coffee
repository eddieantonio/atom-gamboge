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
        logicalIndent = 0

        currentIndentLevel = ->
          lineNum = @editor.getLastBufferRow()
          @editor.indentationForBufferRow(lineNum)

        for token, i in tokens
          count += switch token.category
            when 'INDENT'
              # Auto-indent means no key press.
              logicalIndent += 1
              0
            when 'DEDENT'
              logicalIndent -= 1
              @editor.backspace()
              1
            when 'NEWLINE', 'NL'
              backspaceCounter = 0
              # When we've indented BUT the next token isn't an indent...
              @editor.insertNewlineBelow()
              unless tokens[i + 1]?.category is 'INDENT'
                while currentIndentLevel() > logicalIndent
                  @editor.backspace()
                  backspaceCounter++
              1 + backspaceCounter
            when 'ENDMARKER'
              0
            else
              @editor.insertText token.text
              unless token.category is 'COMMENT'
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


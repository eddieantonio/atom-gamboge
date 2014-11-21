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


{WorkspaceView} = require 'atom'

TextFormatter = require '../lib/text-formatter'

# Test Helper: Joins all its arguments with newlines.
lines = -> Array::join.call(arguments, '\n')
asTokens = (str) -> str.split(' ')

fdescribe 'TextFormatter', ->
  [infoSpy] = []

  beforeEach ->
    infoSpy = jasmine.createSpyObj 'infoSpy',
      ['getIndentLevel', 'getIndentChars']
    infoSpy.getIndentChars.andReturn('  ')

  describe '::constructor()', ->
    it 'constructs with an editor info object', ->
      expect(-> new TextFormatter(infoSpy)).not.toThrow()

  describe 'after instantiation', ->
    [formatter] = []


    beforeEach ->
      formatter = new TextFormatter(infoSpy)

    describe '::format()', ->
      it 'outputs normal tokens as is', ->
        text = formatter.format(['for', 'i', 'in', 'range', '(', '10', ')'])
        expect(text).toBe 'for i in range ( 10 ) '

      it 'properly indents lines', ->
        infoSpy.getIndentLevel.andReturn(0)
        tokens = ['while', '1', ':', '<NEWLINE>', '<INDENT>', 'pass']
        text = formatter.format(tokens)
        expect(text).toBe lines 'while 1 : ',
                                '  pass '

      it 'handles being indented already', ->
        infoSpy.getIndentLevel.andReturn(2)
        tokens = asTokens 'while 1 : <NEWLINE> <INDENT> if True :'
        text = formatter.format(tokens)
        expect(text).toBe lines 'while 1 : ',
                                '      if True : '

      it 'handles double indents', ->
        # Start 2 indents in...
        infoSpy.getIndentLevel.andReturn(2)
        tokens = asTokens 'while 1 : <NEWLINE> <INDENT>
                           if True : <NEWLINE> <INDENT> break'
        text = formatter.format(tokens)
        expect(text).toBe lines 'while 1 : ',
                                '      if True : ',
                                '        break '

      it 'handles dedents', ->
        infoSpy.getIndentLevel.andReturn(1)
        tokens = asTokens 'return self <NEWLINE> <DEDENT> pass'
        text = formatter.format(tokens)
        expect(text).toBe lines 'return self ', 'pass '

      it 'handles dedents when already deeply indented', ->
        infoSpy.getIndentLevel.andReturn(3)
        tokens = asTokens 'return self <NEWLINE> <DEDENT> pass'
        text = formatter.format(tokens)
        expect(text).toBe lines 'return self ', '    pass '

  describe '.makeEditorIndentSpy()', ->
    [editor, indentSpy] = []

    beforeEach ->
      atom.workspaceView = new WorkspaceView
      atom.workspace = atom.workspaceView.model

      waitsForPromise ->
        atom.packages.activatePackage('language-python')

      waitsForPromise ->
        atom.workspace.open('sample.py')

      runs ->
        editor = atom.workspace.getActiveEditor()

        indentSpy = TextFormatter.makeEditorIndentSpy(editor)

    it "creates an object that TextFormatter's constructor craves", ->
      expect(indentSpy.getIndentChars).toBeDefined()
      expect(indentSpy.getIndentLevel).toBeDefined()

      expect(-> new TextFormatter(indentSpy)).not.toThrow()

    it 'returns appropriate values from the text editor', ->
      expect(indentSpy.getIndentChars()).toBe '    '

      editor.setText lines 'class Foo():',
                           '    def __init__(self):',
                           '        pass',

      # On the first line; unindented.
      editor.moveToTop()
      expect(indentSpy.getIndentLevel()).toBe 0

      # In the `def __init__` line.
      editor.moveDown()
      expect(indentSpy.getIndentLevel()).toBe 1

      # On the bottom, most indented line
      editor.moveToBottom()
      expect(indentSpy.getIndentLevel()).toBe 2

      # Almost the same, but starting after the indent on the second line.
      editor.setText lines 'class Foo():',
                           '    def __init__(self):',
                           '        pass',
                           '    '

      editor.moveToBottom()
      expect(indentSpy.getIndentLevel()).toBe 1


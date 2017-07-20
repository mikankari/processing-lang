define (require, exports, module) ->

	class ProcessingCodeHints
		constructor: ->
			@exclusion = null
			@wordlist = JSON.parse require "text!codehints.json"
			@definition = /((void )|(new )|\.)?\w+$/

		hasHints: (editor, implicitChar) ->
			@editor = editor
			cursor = @editor.getCursorPos()

			textBeforeCursor = @editor.document.getRange {line: cursor.line, ch: 0}, cursor

			if matched = textBeforeCursor.match @definition
				return true for key, value of @wordlist when (key.toLowerCase().indexOf matched[0].toLowerCase()) is 0

			false

		getHints: (implicitChar) ->
			cursor = @editor.getCursorPos()

			textBeforeCursor = @editor.document.getRange {line: cursor.line, ch: 0}, cursor

			hintlist = []

			if matched = textBeforeCursor.match @definition
				hintlist.push key for key, value of @wordlist when (key.toLowerCase().indexOf matched[0].toLowerCase()) is 0
			else
				matched = [""]

			{
				"hints": hintlist
				"match": matched[0]
				"selectInitial": true
				"handleWideResults": false
			}

		insertHint: (completion) =>
			cursor = @editor.getCursorPos()

			textBeforeCursor = @editor.document.getRange {line: cursor.line, ch: 0}, cursor

			indexOfText = textBeforeCursor.search @definition
			indexOfParam = indexOfText + completion.length - 1

			hint = @wordlist[completion]

			completion = "#{completion};" if hint.type is "function" and not hint.param[1]
			completion = "#{completion} " if hint.type is "type"

			@editor.document.replaceRange completion, {line: cursor.line, ch: indexOfText}, cursor

			if hint.type is "function" and hint.param[0]
				@editor.setCursorPos cursor.line, indexOfParam
			else if hint.type is "event"
				switch typeof hint.ch
					when "number"
						@editor.setCursorPos cursor.line + hint.line, hint.ch
					when "object"
						@editor.setSelection {"line": cursor.line + hint.line, "ch": hint.ch[0]}, {"line": cursor.line + hint.line, "ch": hint.ch[1]}

			false

	exports.ProcessingCodeHints = ProcessingCodeHints

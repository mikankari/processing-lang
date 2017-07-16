define (require, exports, module) ->

	class ProcessingCodeHints
		constructor: ->
			@exclusion = null
			@wordlist = JSON.parse require "text!codehints.json"
			@definition = /\w{2,}$/

		updateExclusion: ->

		hasHints: (editor, implicitChar) ->
			@editor = editor
			cursor = @editor.getCursorPos()

			textBeforeCursor = @editor.document.getRange {line: cursor.line, ch: 0}, cursor

			cachedWordlist = @wordlist.functions.concat @wordlist.events, @wordlist.types

			if matched = textBeforeCursor.match @definition
				return true for value in cachedWordlist when (value.toLowerCase().indexOf matched[0].toLowerCase()) is 0

			false

		getHints: (implicitChar) ->
			cursor = @editor.getCursorPos()

			textBeforeCursor = @editor.document.getRange {line: cursor.line, ch: 0}, cursor

			cachedWordlist = @wordlist.functions.concat @wordlist.events, @wordlist.types

			hintlist = []

			if matched = textBeforeCursor.match @definition
				hintlist.push value for value in cachedWordlist when (value.toLowerCase().indexOf matched[0].toLowerCase()) is 0
			else
				matched = [""]

			console.log hintlist
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

			@editor.document.replaceRange completion, {line: cursor.line, ch: indexOfText}, cursor



			false


	exports.ProcessingCodeHints = ProcessingCodeHints

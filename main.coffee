define (require, exports, module) ->

	LanguageManager = brackets.getModule "language/LanguageManager"
	DocumentManager = brackets.getModule "document/DocumentManager"
	CommandManager = brackets.getModule "command/CommandManager"
	Commands = brackets.getModule "command/Commands"
	Menus = brackets.getModule "command/Menus"
	FileSystem = brackets.getModule "filesystem/FileSystem"
	ProjectManager = brackets.getModule "project/ProjectManager"

	command_id = "io.github.mikankari.processing-lang.new-project"

	LanguageManager.defineLanguage "processing", {
		"name": "Processing"
		"mode": "clike"
		"fileExtensions": ["pde"]
		"blockComment": ["/*", "*/"]
		"lineComment": ["//"]
	}

	newProjectHandler = ->
		date = new Date()
		name = [
			"sketch_"
			date.getFullYear() % 1000
			"0#{date.getMonth().toString()}"
				.slice -2
			"0#{date.getDate().toString()}"
				.slice -2
			"0#{date.getHours().toString()}"
				.slice -2
			"0#{date.getMinutes().toString()}"
				.slice -2
			"0#{date.getSeconds().toString()}"
				.slice -2
		].join ""

		ProjectManager.createNewItem ProjectManager.getProjectRoot(), name, false, true
			.then (entry) ->
				ProjectManager.createNewItem entry, "#{entry.name}.pde", true, false
			.then (entry) ->
				DocumentManager.getDocumentForPath entry.fullPath
			.done (document) ->
				document.setText require "text!template.pde"

	CommandManager.register "New Processing Project", command_id, newProjectHandler

	file_menu = Menus.getMenu Menus.AppMenuBar.FILE_MENU
	file_menu.addMenuItem command_id, null, Menus.AFTER, Commands.FILE_NEW_UNTITLED

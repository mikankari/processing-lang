define (require, exports, module) ->

	ExtensionUtils = brackets.getModule "utils/ExtensionUtils"
	LanguageManager = brackets.getModule "language/LanguageManager"
	PreferencesManager = brackets.getModule "preferences/PreferencesManager"
	NodeDomain = brackets.getModule "utils/NodeDomain"
	DocumentManager = brackets.getModule "document/DocumentManager"
	CommandManager = brackets.getModule "command/CommandManager"
	Commands = brackets.getModule "command/Commands"
	Menus = brackets.getModule "command/Menus"
	ProjectManager = brackets.getModule "project/ProjectManager"
	PanelManager = brackets.getModule "view/PanelManager"

	extension_id = "processing_lang"
	extension_path = ExtensionUtils.getModulePath module

	createPanel = ->
		$ require "text!panel.html"
			.find ".close"
			.on "click", ->
				panel.close()
			.end()

	newSketchHandler = ->
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

	runSketchHandler = ->
		CommandManager.execute Commands.FILE_SAVE_ALL

		path = DocumentManager.getCurrentDocument()
			.file.parentPath

		executable = preferences.get "executable"

		domain.exec "run", path, executable

		$ "##{extension_id} .console"
			.empty()

		panel.show()

	stopSketchHandler = ->
		domain.exec "stop"

	LanguageManager.defineLanguage "processing", {
		"name": "Processing"
		"mode": "clike"
		"fileExtensions": ["pde"]
		"blockComment": ["/*", "*/"]
		"lineComment": ["//"]
	}

	preferences = PreferencesManager.getExtensionPrefs extension_id
	preferences.definePreference "executable", "string", "/usr/local/bin/processing-java"

	domain = new NodeDomain "#{extension_id}-run", "#{extension_path}domain"

	domain.on "data", (event, data) ->
		$ "##{extension_id} .console"
			.append "<div>#{data}</div>"

	domain.on "error", (event, error) ->
		$ "##{extension_id} .console"
			.append "<div class=\"text-danger\">#{error}</div>"

	CommandManager.register "New Sketch", "#{extension_id}-new", newSketchHandler
	CommandManager.register "Run", "#{extension_id}-run", runSketchHandler
	CommandManager.register "Stop", "#{extension_id}-stop", stopSketchHandler

	menu = Menus.addMenu "Processing", extension_id, Menus.AFTER, Menus.AppMenuBar.NAVIGATE_MENU
	menu.addMenuItem "#{extension_id}-new", null
	menu.addMenuDivider()
	menu.addMenuItem "#{extension_id}-run", null
	menu.addMenuItem "#{extension_id}-stop", null

	panel = PanelManager.createBottomPanel "#{extension_id}-panel", createPanel(), 100

	ExtensionUtils.loadStyleSheet module, "panel.css"


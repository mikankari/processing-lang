define (require, exports, module) ->

	ExtensionUtils = brackets.getModule "utils/ExtensionUtils"
	AppInit = brackets.getModule "utils/AppInit"
	LanguageManager = brackets.getModule "language/LanguageManager"
	PreferencesManager = brackets.getModule "preferences/PreferencesManager"
	NodeDomain = brackets.getModule "utils/NodeDomain"
	CodeHintManager = brackets.getModule "editor/CodeHintManager"
	DocumentManager = brackets.getModule "document/DocumentManager"
	EditorManager = brackets.getModule "editor/EditorManager"
	Dialogs = brackets.getModule "widgets/Dialogs"
	CommandManager = brackets.getModule "command/CommandManager"
	Commands = brackets.getModule "command/Commands"
	Menus = brackets.getModule "command/Menus"
	ProjectManager = brackets.getModule "project/ProjectManager"
	WorkspaceManager = brackets.getModule "view/WorkspaceManager"

	ProcessingCodeHints = require "codehints"

	extension_id = "processing_lang"
	extension_path = ExtensionUtils.getModulePath module
	preferences = null
	domain = null
	codehints = null
	menu = null
	panel = null

	createPanel = ->
		$ require "text!panel.html"
			.find ".close"
			.on "click", ->
				panel.hide()
			.end()

	createConfigDialog = ->
		$ require "text!config.html"
			.find "#processing_lang-executable"
			.val preferences.get "executable"
			.end()
			.find ".primary"
			.on "click", ->
				value = $ "#processing_lang-executable"
					.val()
				preferences.set "executable", value
			.end()

	securePath = (path) ->
		if path.indexOf " " isnt -1 then "\"#{path}\"" else path

	secureOutput = (data) ->
		secured = data
		secured = secured.replace /&/g, "&amp;"
		secured = secured.replace /</g, "&lt;"
		secured = secured.replace />/g, "&gt;"

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
				template = JSON.parse require "text!template.json"
				switch typeof template
					when "number"
						EditorManager.getCurrentFullEditor().setCursorPos template.line, template.ch
					when "object"
						EditorManager.getCurrentFullEditor().setSelection {line: template.line, ch: template.ch[0]}, {line: template.line, ch: template.ch[1]}

	runSketchHandler = ->
		CommandManager.execute Commands.FILE_SAVE_ALL

		path = securePath DocumentManager.getCurrentDocument().file.parentPath

		executable = securePath preferences.get "executable"

		domain.exec "run", path, executable

		$ "##{extension_id} .console"
			.empty()

		panel.show()

	stopSketchHandler = ->
		domain.exec "stop"

	configHandler = ->
		Dialogs.showModalDialogUsingTemplate createConfigDialog()

	AppInit.appReady ->
		LanguageManager.defineLanguage "processing", {
			"name": "Processing"
			"mode": ["clike", "text/x-java"]
			"fileExtensions": ["pde"]
			"blockComment": ["/*", "*/"]
			"lineComment": ["//"]
		}

		preferences = PreferencesManager.getExtensionPrefs extension_id
		preferences.definePreference "executable", "string", "/usr/local/bin/processing-java"

		PreferencesManager.definePreference "codehint.ProcessingCodeHints", "boolean", true

		domain = new NodeDomain "#{extension_id}-run", "#{extension_path}domain"

		domain.on "data", (event, data) ->
			$ "##{extension_id} .console"
				.append "<div>#{secureOutput data}</div>"

		domain.on "error", (event, error) ->
			$ "##{extension_id} .console"
				.append "<div class=\"text-danger\">#{secureOutput error}</div>"

		codehints = new ProcessingCodeHints()
		CodeHintManager.registerHintProvider codehints, ["processing"], 0

		CommandManager.register "New Sketch", "#{extension_id}-new", newSketchHandler
		CommandManager.register "Run", "#{extension_id}-run", runSketchHandler
		CommandManager.register "Stop", "#{extension_id}-stop", stopSketchHandler
		CommandManager.register "Config", "#{extension_id}-config", configHandler

		menu = Menus.addMenu "Processing", extension_id, Menus.AFTER, Menus.AppMenuBar.NAVIGATE_MENU
		menu.addMenuItem "#{extension_id}-new", null
		menu.addMenuDivider()
		menu.addMenuItem "#{extension_id}-run", "F7"
		menu.addMenuItem "#{extension_id}-stop", null
		menu.addMenuDivider()
		menu.addMenuItem "#{extension_id}-config", null

		panel = WorkspaceManager.createBottomPanel "#{extension_id}-panel", createPanel(), 100

		ExtensionUtils.loadStyleSheet module, "panel.css"

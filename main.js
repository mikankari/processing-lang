(function() {
  define(function(require, exports, module) {
    var AppInit, CodeHintManager, CommandManager, Commands, Dialogs, DocumentManager, EditorManager, ExtensionUtils, LanguageManager, Menus, NodeDomain, PreferencesManager, ProcessingCodeHints, ProjectManager, WorkspaceManager, codehints, configHandler, createConfigDialog, createPanel, domain, extension_id, extension_path, menu, newSketchHandler, panel, preferences, runSketchHandler, secureOutput, securePath, stopSketchHandler;
    ExtensionUtils = brackets.getModule("utils/ExtensionUtils");
    AppInit = brackets.getModule("utils/AppInit");
    LanguageManager = brackets.getModule("language/LanguageManager");
    PreferencesManager = brackets.getModule("preferences/PreferencesManager");
    NodeDomain = brackets.getModule("utils/NodeDomain");
    CodeHintManager = brackets.getModule("editor/CodeHintManager");
    DocumentManager = brackets.getModule("document/DocumentManager");
    EditorManager = brackets.getModule("editor/EditorManager");
    Dialogs = brackets.getModule("widgets/Dialogs");
    CommandManager = brackets.getModule("command/CommandManager");
    Commands = brackets.getModule("command/Commands");
    Menus = brackets.getModule("command/Menus");
    ProjectManager = brackets.getModule("project/ProjectManager");
    WorkspaceManager = brackets.getModule("view/WorkspaceManager");
    ProcessingCodeHints = require("codehints");
    extension_id = "processing_lang";
    extension_path = ExtensionUtils.getModulePath(module);
    preferences = null;
    domain = null;
    codehints = null;
    menu = null;
    panel = null;
    createPanel = function() {
      return $(require("text!panel.html")).find(".close").on("click", function() {
        return panel.hide();
      }).end();
    };
    createConfigDialog = function() {
      return $(require("text!config.html")).find("#processing_lang-executable").val(preferences.get("executable")).end().find(".primary").on("click", function() {
        var value;
        value = $("#processing_lang-executable").val();
        return preferences.set("executable", value);
      }).end();
    };
    securePath = function(path) {
      if (path.indexOf(" " !== -1)) {
        return "\"" + path + "\"";
      } else {
        return path;
      }
    };
    secureOutput = function(data) {
      var secured;
      secured = data;
      secured = secured.replace(/&/g, "&amp;");
      secured = secured.replace(/</g, "&lt;");
      return secured = secured.replace(/>/g, "&gt;");
    };
    newSketchHandler = function() {
      var date, name;
      date = new Date();
      name = ["sketch_", date.getFullYear() % 1000, ("0" + (date.getMonth().toString())).slice(-2), ("0" + (date.getDate().toString())).slice(-2), ("0" + (date.getHours().toString())).slice(-2), ("0" + (date.getMinutes().toString())).slice(-2), ("0" + (date.getSeconds().toString())).slice(-2)].join("");
      return ProjectManager.createNewItem(ProjectManager.getProjectRoot(), name, false, true).then(function(entry) {
        return ProjectManager.createNewItem(entry, "" + entry.name + ".pde", true, false);
      }).then(function(entry) {
        return DocumentManager.getDocumentForPath(entry.fullPath);
      }).done(function(document) {
        var template;
        document.setText(require("text!template.pde"));
        template = JSON.parse(require("text!template.json"));
        switch (typeof template) {
          case "number":
            return EditorManager.getCurrentFullEditor().setCursorPos(template.line, template.ch);
          case "object":
            return EditorManager.getCurrentFullEditor().setSelection({
              line: template.line,
              ch: template.ch[0]
            }, {
              line: template.line,
              ch: template.ch[1]
            });
        }
      });
    };
    runSketchHandler = function() {
      var executable, path;
      CommandManager.execute(Commands.FILE_SAVE_ALL);
      path = securePath(DocumentManager.getCurrentDocument().file.parentPath);
      executable = securePath(preferences.get("executable"));
      domain.exec("run", path, executable);
      $("#" + extension_id + " .console").empty();
      return panel.show();
    };
    stopSketchHandler = function() {
      return domain.exec("stop");
    };
    configHandler = function() {
      return Dialogs.showModalDialogUsingTemplate(createConfigDialog());
    };
    return AppInit.appReady(function() {
      LanguageManager.defineLanguage("processing", {
        "name": "Processing",
        "mode": ["clike", "text/x-java"],
        "fileExtensions": ["pde"],
        "blockComment": ["/*", "*/"],
        "lineComment": ["//"]
      });
      preferences = PreferencesManager.getExtensionPrefs(extension_id);
      preferences.definePreference("executable", "string", "/usr/local/bin/processing-java");
      PreferencesManager.definePreference("codehint.ProcessingCodeHints", "boolean", true);
      domain = new NodeDomain("" + extension_id + "-run", "" + extension_path + "domain");
      domain.on("data", function(event, data) {
        return $("#" + extension_id + " .console").append("<div>" + (secureOutput(data)) + "</div>");
      });
      domain.on("error", function(event, error) {
        return $("#" + extension_id + " .console").append("<div class=\"text-danger\">" + (secureOutput(error)) + "</div>");
      });
      codehints = new ProcessingCodeHints();
      CodeHintManager.registerHintProvider(codehints, ["processing"], 0);
      CommandManager.register("New Sketch", "" + extension_id + "-new", newSketchHandler);
      CommandManager.register("Run", "" + extension_id + "-run", runSketchHandler);
      CommandManager.register("Stop", "" + extension_id + "-stop", stopSketchHandler);
      CommandManager.register("Config", "" + extension_id + "-config", configHandler);
      menu = Menus.addMenu("Processing", extension_id, Menus.AFTER, Menus.AppMenuBar.NAVIGATE_MENU);
      menu.addMenuItem("" + extension_id + "-new", null);
      menu.addMenuDivider();
      menu.addMenuItem("" + extension_id + "-run", "F7");
      menu.addMenuItem("" + extension_id + "-stop", null);
      menu.addMenuDivider();
      menu.addMenuItem("" + extension_id + "-config", null);
      panel = WorkspaceManager.createBottomPanel("" + extension_id + "-panel", createPanel(), 100);
      return ExtensionUtils.loadStyleSheet(module, "panel.css");
    });
  });

}).call(this);

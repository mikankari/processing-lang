var LanguageManager;

LanguageManager = brackets.getModule("language/LanguageManager");

LanguageManager.defineLanguage("processing", {
  "name": "Processing",
  "mode": "clike",
  "fileExtensions": ["pde"],
  "blockComment": ["/*", "*/"],
  "lineComment": ["//"]
});

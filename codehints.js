(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require, exports, module) {
    var ProcessingCodeHints;
    ProcessingCodeHints = (function() {
      function ProcessingCodeHints() {
        this.insertHint = __bind(this.insertHint, this);
        this.exclusion = null;
        this.wordlist = JSON.parse(require("text!codehints.json"));
        this.definition = /((void )|(new )|\.)?\w+$/;
      }

      ProcessingCodeHints.prototype.hasHints = function(editor, implicitChar) {
        var cursor, key, matched, textBeforeCursor, value, _ref;
        this.editor = editor;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        if (matched = textBeforeCursor.match(this.definition)) {
          _ref = this.wordlist;
          for (key in _ref) {
            value = _ref[key];
            if ((key.toLowerCase().indexOf(matched[0].toLowerCase())) === 0) {
              return true;
            }
          }
        }
        return false;
      };

      ProcessingCodeHints.prototype.getHints = function(implicitChar) {
        var cursor, hintlist, key, matched, textBeforeCursor, value, _ref;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        hintlist = [];
        if (matched = textBeforeCursor.match(this.definition)) {
          _ref = this.wordlist;
          for (key in _ref) {
            value = _ref[key];
            if ((key.toLowerCase().indexOf(matched[0].toLowerCase())) === 0) {
              hintlist.push(key);
            }
          }
        } else {
          matched = [""];
        }
        return {
          "hints": hintlist,
          "match": matched[0],
          "selectInitial": true,
          "handleWideResults": false
        };
      };

      ProcessingCodeHints.prototype.insertHint = function(completion) {
        var cursor, hint, indexOfParam, indexOfText, textBeforeCursor;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        indexOfText = textBeforeCursor.search(this.definition);
        indexOfParam = indexOfText + completion.length - 1;
        hint = this.wordlist[completion];
        if (hint.type === "function" && !hint.param[1]) {
          completion = "" + completion + ";";
        }
        if (hint.type === "type") {
          completion = "" + completion + " ";
        }
        this.editor.document.replaceRange(completion, {
          line: cursor.line,
          ch: indexOfText
        }, cursor);
        if (hint.type === "function" && hint.param[0]) {
          this.editor.setCursorPos(cursor.line, indexOfParam);
        } else if (hint.type === "event") {
          switch (typeof hint.ch) {
            case "number":
              this.editor.setCursorPos(cursor.line + hint.line, indexOfText + hint.ch);
              break;
            case "object":
              this.editor.setSelection({
                "line": cursor.line + hint.line,
                "ch": indexOfText + hint.ch[0]
              }, {
                "line": cursor.line + hint.line,
                "ch": indexOfText + hint.ch[1]
              });
          }
        }
        return false;
      };

      return ProcessingCodeHints;

    })();
    return exports.ProcessingCodeHints = ProcessingCodeHints;
  });

}).call(this);

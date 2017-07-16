(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require, exports, module) {
    var ProcessingCodeHints;
    ProcessingCodeHints = (function() {
      function ProcessingCodeHints() {
        this.insertHint = __bind(this.insertHint, this);
        this.exclusion = null;
        this.wordlist = JSON.parse(require("text!codehints.json"));
        this.definition = /\w{2,}$/;
      }

      ProcessingCodeHints.prototype.updateExclusion = function() {};

      ProcessingCodeHints.prototype.hasHints = function(editor, implicitChar) {
        var cachedWordlist, cursor, matched, textBeforeCursor, value, _i, _len;
        this.editor = editor;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        cachedWordlist = this.wordlist.functions.concat(this.wordlist.events, this.wordlist.types);
        if (matched = textBeforeCursor.match(this.definition)) {
          for (_i = 0, _len = cachedWordlist.length; _i < _len; _i++) {
            value = cachedWordlist[_i];
            if ((value.toLowerCase().indexOf(matched[0].toLowerCase())) === 0) {
              return true;
            }
          }
        }
        return false;
      };

      ProcessingCodeHints.prototype.getHints = function(implicitChar) {
        var cachedWordlist, cursor, hintlist, matched, textBeforeCursor, value, _i, _len;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        cachedWordlist = this.wordlist.functions.concat(this.wordlist.events, this.wordlist.types);
        hintlist = [];
        if (matched = textBeforeCursor.match(this.definition)) {
          for (_i = 0, _len = cachedWordlist.length; _i < _len; _i++) {
            value = cachedWordlist[_i];
            if ((value.toLowerCase().indexOf(matched[0].toLowerCase())) === 0) {
              hintlist.push(value);
            }
          }
        } else {
          matched = [""];
        }
        console.log(hintlist);
        return {
          "hints": hintlist,
          "match": matched[0],
          "selectInitial": true,
          "handleWideResults": false
        };
      };

      ProcessingCodeHints.prototype.insertHint = function(completion) {
        var cursor, indexOfText, textBeforeCursor;
        cursor = this.editor.getCursorPos();
        textBeforeCursor = this.editor.document.getRange({
          line: cursor.line,
          ch: 0
        }, cursor);
        indexOfText = textBeforeCursor.search(this.definition);
        this.editor.document.replaceRange(completion, {
          line: cursor.line,
          ch: indexOfText
        }, cursor);
        return false;
      };

      return ProcessingCodeHints;

    })();
    return exports.ProcessingCodeHints = ProcessingCodeHints;
  });

}).call(this);

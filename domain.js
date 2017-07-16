(function() {
  var ChildProcess, treekill, _domainManager, _domain_id, _run, _running, _stop;

  ChildProcess = require("child_process");

  treekill = require("tree-kill");

  _domainManager = null;

  _running = null;

  _domain_id = "processing_lang-run";

  _run = function(path, executable, callback) {
    return _stop(function() {
      _running = ChildProcess.exec("" + executable + " --sketch=" + path + " --output=" + path + "build --force --run");
      _running.stdout.on("data", function(data) {
        return _domainManager.emitEvent(_domain_id, "data", data);
      });
      _running.stderr.on("data", function(data) {
        return _domainManager.emitEvent(_domain_id, "error", data);
      });
      return callback();
    });
  };

  _stop = function(callback) {
    if (_running != null) {
      return treekill(_running.pid, "SIGTERM", callback);
    } else {
      return callback();
    }
  };

  exports.init = function(DomainManager) {
    if (!DomainManager.hasDomain(_domain_id)) {
      DomainManager.registerDomain(_domain_id, {
        "major": 0,
        "minor": 1
      });
    }
    _domainManager = DomainManager;
    DomainManager.registerCommand(_domain_id, "run", _run, true, "run a sketch", [
      {
        "name": "path",
        "type": "string",
        "description": "path for a sketch direcotry"
      }, {
        "name": "executable",
        "type": "string",
        "description": "path for the processing-java file"
      }
    ], []);
    DomainManager.registerCommand(_domain_id, "stop", _stop, true, "stop a running sketch", [], []);
    DomainManager.registerEvent(_domain_id, "data", [
      {
        "name": "data",
        "type": "string",
        "description": "stdout text from a running sketch"
      }
    ]);
    return DomainManager.registerEvent(_domain_id, "error", [
      {
        "name": "error",
        "type": "string",
        "description": "stderr text from a running sketch"
      }
    ]);
  };

}).call(this);

(function() {
  var ChildProcess, treekill, _domainManager, _domain_id, _run, _running;

  ChildProcess = require("child_process");

  treekill = require("tree-kill");

  _domainManager = null;

  _running = null;

  _domain_id = "processing_lang-run";

  _run = function(path, executable, callback) {
    if (_running != null) {
      treekill(_running.pid);
    }
    _running = ChildProcess.exec("" + executable + " --sketch=" + path + " --output=" + path + "build --force --run");
    _running.stdout.on("data", function(data) {
      return _domainManager.emitEvent(_domain_id, "data", data);
    });
    _running.stderr.on("data", function(data) {
      return _domainManager.emitEvent(_domain_id, "error", data);
    });
    return callback();
  };

  exports.init = function(DomainManager) {
    if (!DomainManager.hasDomain(_domain_id)) {
      DomainManager.registerDomain(_domain_id, {
        "major": 0,
        "minor": 1
      });
    }
    _domainManager = DomainManager;
    DomainManager.registerCommand(_domain_id, "run", _run, true, "execute", [
      {
        "name": "path",
        "type": "string",
        "description": ""
      }, {
        "name": "executable",
        "type": "string",
        "description": ""
      }
    ], []);
    DomainManager.registerEvent(_domain_id, "data", [
      {
        "name": "data",
        "type": "string"
      }
    ]);
    return DomainManager.registerEvent(_domain_id, "error", [
      {
        "name": "error",
        "type": "string"
      }
    ]);
  };

}).call(this);

ChildProcess = require "child_process"
treekill = require "tree-kill"

_domainManager = null
_running = null
_domain_id = "processing_lang-run"

_run = (path, executable, callback) ->
	_stop ->
		_running = ChildProcess.exec "#{executable} --sketch=#{path} --output=#{path}build --force --run"

		_running.stdout.on "data", (data) ->
			_domainManager.emitEvent _domain_id, "data", data

		_running.stderr.on "data", (data) ->
			_domainManager.emitEvent _domain_id, "error", data

		callback()

_stop = (callback) ->
	if _running?
		treekill _running.pid, "SIGTERM", callback
	else
		callback()

exports.init = (DomainManager) ->
	if not DomainManager.hasDomain _domain_id
		DomainManager.registerDomain _domain_id, {
			"major": 0, "minor": 1
		}
	_domainManager = DomainManager

	DomainManager.registerCommand _domain_id,
		"run",
		_run,
		true,
		"run a sketch",
		[
			{
				"name": "path"
				"type": "string"
				"description": "path for a sketch direcotry"
			}
			{
				"name": "executable"
				"type": "string"
				"description": "path for the processing-java file"
			}
		],
		[]
	DomainManager.registerCommand _domain_id,
		"stop"
		_stop
		true
		"stop a running sketch"
		[]
		[]

	DomainManager.registerEvent _domain_id,
		"data",
		[
			{
				"name": "data"
				"type": "string"
				"description": "stdout text from a running sketch"
			}
		]
	DomainManager.registerEvent _domain_id,
		"error",
		[
			{
				"name": "error"
				"type": "string"
				"description": "stderr text from a running sketch"
			}
		]


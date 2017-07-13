ChildProcess = require "child_process"
treekill = require "tree-kill"

_domainManager = null
_running = null
_domain_id = "processing_lang-run"

_run = (path, executable, callback) ->
	treekill _running.pid if _running?

	_running = ChildProcess.exec "#{executable} --sketch=#{path} --output=#{path}build --force --run"

	_running.stdout.on "data", (data) ->
		_domainManager.emitEvent _domain_id, "data", data

	_running.stderr.on "data", (data) ->
		_domainManager.emitEvent _domain_id, "error", data

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
		"execute",
		[
			{
				"name": "path"
				"type": "string"
				"description": ""
			}
			{
				"name": "executable"
				"type": "string"
				"description": ""
			}
		],
		[]

	DomainManager.registerEvent _domain_id,
		"data",
		[
			{
				"name": "data"
				"type": "string"
			}
		]
	DomainManager.registerEvent _domain_id,
		"error",
		[
			{
				"name": "error"
				"type": "string"
			}
		]


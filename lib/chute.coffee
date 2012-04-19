request = require 'request'

class Chute # Main class, client
	
	constructor: (options = {}) ->
		@options= # setting default options
			endpoint: 'http://api.getchute.com/v1'
		@set options
	
	set: (options = {}) ->
		for key of options # overriding default options
			@options[key] = options[key]
		
		do @initializeResources # we need to reinitialize resources with the new options(may be new endpoint, token, etc)
	
	initializeResources: ->
		@chutes = new Chutes @
		###
		@parcels = new Parcels @
		@assets = new Assets @
		@bundles = new Bundles @
		###

class Chutes
	
	constructor: (@client) -> # getting link to client and ability to get options
	
	all: (callback) -> # getting all chutes
		request
			url: "#{ @client.options.endpoint }/me/chutes"
			method: 'GET'
			qs:
				oauth_token: @client.options.token
		, (err, res, body) ->
			if res.statusCode is 401
				body=
					error: body
			else
				body = JSON.parse body
			if not err and res.statusCode is 200
				callback no, body.data
			else
				callback body.error, []
	
	find: (options, callback) -> # finding only one chute, options should be { id: 1123123|'shortcut' }
		id = options.id or options.shortcut
		request
			url: "#{ @client.options.endpoint }/chutes/#{ id }"
			method: 'GET'
			qs:
				oauth_token: @client.options.token
		, (err, res, body) ->
			if res.statusCode is 401
				body=
					error: body
			else
				body = JSON.parse body
			if not err and res.statusCode is 200
				callback no, body.data
			else
				callback body.error, []
	
	create: (options, callback) -> # creating chute, options should be { name: 'Name of the Chute' }
		request
			url: "#{ @client.options.endpoint }/chutes"
			method: 'POST'
			qs:
				oauth_token: @client.options.token
			form:
				'chute[name]': options.name
		, (err, res, body) ->
			if res.statusCode is 401
				body=
					error: body
			else
				body = JSON.parse body
			if not err and res.statusCode is 201
				callback no, body.data
			else
				callback body.error, {}
	
	update: (options, callback) -> # updating chute, options should be { name: 'New name for the Chute', id: 1243234|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'PUT'
			qs:
				oauth_token: @client.options.token
			form:
				'chute[name]': options.name
		, (err, res, body) ->
			if res.statusCode is 401
				body=
					error: body
			else
				body = JSON.parse body
			if not err and res.statusCode is 200
				callback no, body.data
			else
				callback body.error
	
	remove: (options, callback) -> # removing chute, options should be { id: 123235|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'DELETE'
			qs:
				oauth_token: @client.options.token
		, (err, res, body) ->
			if not err and res.statusCode is 200
				callback no
			else
				callback if res.statusCode is 401 then body else JSON.parse(body).error
	
module.exports = Chute
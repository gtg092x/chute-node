request = require 'request'
fs = require 'fs'

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
		@parcels = new Parcels @
		@uploads = new Uploads @
		@assets = new Assets @
		@bundles = new Bundles @

class Bundles
	
	constructor: (@client) -> # getting link to client and ability to read options
	
	create: (options, callback) -> # creating bundle of existing assets
		request
			url: "#{ @client.options.endpoint }/bundles"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				asset_ids: JSON.stringify options.ids
		, (err, res, body) ->
			switch res.statusCode
				when 201 then callback no, JSON.parse(body)
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	find: (options, callback) -> # finding a bundle, options should be { id: 135235 }
		that = @
		request
			url: "#{ @client.options.endpoint }/bundles/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	remove: (options, callback) ->
		request
			url: "#{ @client.options.endpoint }/bundles/#{ options.id or options.shortcut }"
			method: 'DELETE'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, {}
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
class Assets
	
	constructor: (@client) -> # getting link to client and ability to read options
	
	find: (options, callback) -> # finding assets, options should be { id: 125235|'asfsdgdfg', chuteId: 2352435|'hrdgfdh', comments: yes|no }
		that = @
		request
			url: "#{ @client.options.endpoint }/assets/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200
					asset = JSON.parse(body).data
					return callback no, asset if not options.comments
					
					request
						url: "#{ that.client.options.endpoint }/chutes/#{ options.chuteId or options.chute }/assets/#{ options.id or options.shortcut }/comments"
						method: 'GET'
						headers:
							'x-client_id': that.client.options.id
							'Authorization': "OAUTH #{ that.client.options.token }"
					, (err, res, body) ->
						switch res.statusCode
							when 200
								asset.comments = JSON.parse(body).data
								callback no, asset
							when 401 then callback 'invalid access token', {}
							else callback JSON.parse(body).error, {}
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	remove: (options, callback) -> # removing asset, options should be { id: 12352345|'sdfgsdfgsdfg' }
		if options.id
			url = "#{ @client.options.endpoint }/assets/#{ options.id or options.shortcut }"
			method = 'DELETE'
			form = {}
		
		if options.ids
			url = "#{ @client.options.endpoint }/assets/remove"
			method = 'POST'
			form=
				asset_ids: JSON.stringify(options.ids)
		
		request
			url: url
			method: method
			form: form
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}

class Uploads
	
	constructor: (@client) -> # getting link to client and ability to read options
	
	generateToken: (options, callback) -> # generating token for upload
		request
			url: "#{ @client.options.endpoint }/uploads/#{ options.id or options.shortcut }/token"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse body
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	upload: (options, callback) -> # uploading to S3 using provided signed URL
		remote = request
			url: options.upload_url
			method: 'PUT'
			headers:
				'Authorization': options.signature
				'Date': options.date
				'Content-Type': options.content_type
				'Content-Length': options.md5
				'x-amz-acl': 'public-read'
		, (err, res, body) ->
			if body is ''
				callback no if callback
			else
				callback body if callback
		
		stream = fs.createReadStream options.file_path
		
		stream.pipe remote
	
	complete: (options, callback) -> # finishing upload
		request
			url: "#{ @client.options.endpoint }/uploads/#{ options.id or options.asset_id or options.shortcut }/complete"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse body
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}

class Parcels
	
	constructor: (@client) -> # getting link to client and ability to read options
	
	find: (options, callback) -> # finding parcel, options should be { id: 1252345 }
		request
			url: "#{ @client.options.endpoint }/parcels/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse body
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	create: (options, callback) -> # creating parcel, options should be { files: [], assets: [], chutes: [] }
		request
			url: "#{ @client.options.endpoint }/parcels"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				files: JSON.stringify options.files
				chutes: JSON.stringify options.chutes
		, (err, res, body) ->
			switch res.statusCode
				when 201 then callback no, JSON.parse body
				when 401 then callback 'invalid access token', []
				else callback JSON.parse(body).error, []

class Chutes
	
	constructor: (@client) -> # getting link to client and ability to get options
	
	all: (callback) -> # getting all chutes
		request
			url: "#{ @client.options.endpoint }/me/chutes"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', []
				else callback JSON.parse(body).error, []
	
	find: (options, callback) -> # finding only one chute, options should be { id: 1123123|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', []
				else callback JSON.parse(body).error, []
	
	create: (options, callback) -> # creating chute, options should be { name: 'Name of the Chute' }
		request
			url: "#{ @client.options.endpoint }/chutes"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				'chute[name]': options.name
		, (err, res, body) ->
			switch res.statusCode
				when 201 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	update: (options, callback) -> # updating chute, options should be { name: 'New name for the Chute', id: 1243234|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'PUT'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				'chute[name]': options.name
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}
	
	remove: (options, callback) -> # removing chute, options should be { id: 123235|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'DELETE'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no
				when 401 then callback 'invalid access token'
				else callback JSON.parse(body).error
	
module.exports = Chute
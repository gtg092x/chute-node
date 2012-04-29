request = require 'request'
fs = require 'fs'
async = require 'async'

# Monkey patching for asset URLs

String::width = (width) ->
	@options = {} if not @options
	@options.width = width
	@

String::height = (height) ->
	@options = {} if not @options
	@options.height = height
	@

String::fit = ->
	@options = {} if not @options
	@options.fit = yes
	@

String::build = ->
	type = if @options.fit then 'fit' else 'fill'
	type = 'fixed width' if @options.width and not @options.height
	type = 'fixed height' if @options.height and not @options.width 
	switch type
		when 'fit' then "#{ @ }/fit/#{ @options.width }x#{ @options.height }"
		when 'fixed width' then "#{ @ }/w/#{ @options.width }"
		when 'fixed height' then "#{ @ }/h/#{ @options.height }"
		when 'fill' then "#{ @ }/#{ @options.width }x#{ @options.height }"
		else @

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
	
	search: (options, callback) -> # general search method
		options.type = 'all' if not options.type
		request
			url: "#{ @options.endpoint }/meta/#{ options.type }/#{ options.key }"
			method: 'GET'
			headers:
				'x-client_id': @options.id
				'Authorization': "OAUTH #{ @options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 201 then callback no, JSON.parse(body).data
				when 401 then callback 'invalid access token', {}
				else callback JSON.parse(body).error, {}

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
	
	heart: (options, callback) -> # heart an asset, options should be { id: 125235|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/assets/#{ options.id or options.shortcut }/heart"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no
				else callback yes
	
	unheart: (options, callback) -> # unheart an asset, options should be { id: 125235|'shortcut' }
		request
			url: "#{ @client.options.endpoint }/assets/#{ options.id or options.shortcut }/unheart"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no
				else callback yes
	
	search: (options, callback) -> # searching for assets, options should be { key: 'id' }
		@client.search type: 'assets', key: options.key, callback
	
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
	
	search: (options, callback) -> # searching for parcels, options should be { key: 'id' }
		@client.search type: 'parcels', key: options.key, callback

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
	
	addAssets: (options, callback) -> # adding assets to a specific chute, options should be { id: 1235235|'shortcut', ids: [], assets: [] }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }/assets/add"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				asset_ids: JSON.stringify(options.ids or options.assets)
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no
				else callback yes
	
	removeAssets: (options, callback) -> # removing assets to a specific chute, options should be { id: 1235235|'shortcut', ids: [], assets: [] }
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }/assets/remove"
			method: 'POST'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
			form:
				asset_ids: JSON.stringify(options.ids or options.assets)
		, (err, res, body) ->
			switch res.statusCode
				when 200 then callback no
				else callback yes
	
	find: (options, callback) -> # finding only one chute, options should be { id: 1123123|'shortcut' }
		that = @
		request
			url: "#{ @client.options.endpoint }/chutes/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) ->
			switch res.statusCode
				when 200
					chute = JSON.parse(body).data
					return callback no, chute if not (options.contributors or options.members or options.parcels)
					
					findContributors = (done) ->
						request
							url: "#{ that.client.options.endpoint }/chutes/#{ options.id or options.shortcut }/contributors"
							method: 'GET'
							headers:
								'x-client_id': that.client.options.id
								'Authorization': "OAUTH #{ that.client.options.token }"
						, (err, res, body) ->
							chute.contributors = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					findMembers = (done) ->
						request
							url: "#{ that.client.options.endpoint }/chutes/#{ options.id or options.shortcut }/members"
							method: 'GET'
							headers:
								'x-client_id': that.client.options.id
								'Authorization': "OAUTH #{ that.client.options.token }"
						, (err, res, body) ->
							chute.members = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					findParcels = (done) ->
						request
							url: "#{ that.client.options.endpoint }/chutes/#{ options.id or options.shortcut }/parcels"
							method: 'GET'
							headers:
								'x-client_id': that.client.options.id
								'Authorization': "OAUTH #{ that.client.options.token }"
						, (err, res, body) ->
							chute.parcels = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					methods = []
					methods.push findContributors if options.contributors
					methods.push findMembers if options.members
					methods.push findParcels if options.parcels
					
					async.parallel methods, ->
						callback no, chute
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
	
	search: (options, callback) -> # searching for chutes, options should be { key: 'id' }
		@client.search type: 'chutes', key: options.key, callback
	
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
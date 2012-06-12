request = require 'request'
fs = require 'fs'
async = require 'async'

# Methods for asset URLs

String::width = (width) -> "#{ @ }/w/#{ width }"
	
String::height = (height) -> "#{ @ }/h/#{ height }"

String::fit = (width, height) -> "#{ @ }/fit/#{ width }x#{ height }"

String::fill = (width, height) -> "#{ @ }/#{ width }x#{ height }"

class Chute # Main class, client
	constructor: (options = {}) ->
		@options = {}
		
		@set options
	
	set: (options = {}) ->
		for key of options # overriding default options
			@options[key] = options[key]
		
		do @initializeResources # we need to reinitialize resources with the new options(may be new endpoint, token, etc)
	
	initializeResources: ->
		@chutes = new Chutes @
		@uploads = new Uploads @
		@assets = new Assets @
		@bundles = new Bundles @
	
	search: (options, callback) -> # general search method
		options.type = 'all' if not options.type
		
		request
			url: "http://api.getchute.com/v1/meta/#{ options.type }/#{ options.key }"
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
			url: "http://api.getchute.com/v1/bundles"
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
		request
			url: "http://api.getchute.com/v1/bundles/#{ options.id or options.shortcut }"
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
			url: "http://api.getchute.com/v1/bundles/#{ options.id or options.shortcut }"
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
		request
			url: "http://api.getchute.com/v1/assets/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) =>
			switch res.statusCode
				when 200
					asset = JSON.parse(body).data
					return callback no, asset if not options.comments
					
					request
						url: "http://api.getchute.com/v1/chutes/#{ options.chuteId or options.chute }/assets/#{ options.id or options.shortcut }/comments"
						method: 'GET'
						headers:
							'x-client_id': @client.options.id
							'Authorization': "OAUTH #{ @client.options.token }"
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
			url: "http://api.getchute.com/v1/assets/#{ options.id or options.shortcut }/heart"
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
			url: "http://api.getchute.com/v1/assets/#{ options.id or options.shortcut }/unheart"
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
			url = "http://api.getchute.com/v1/assets/#{ options.id or options.shortcut }"
			method = 'DELETE'
			form = {}
		
		if options.ids
			url = "http://api.getchute.com/v1/assets/remove"
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
	
	upload: (options, callback) -> # generating token for an upload
		request
			url: "http://api.getchute.com/v2/uploads"
			method: 'POST'
			body: JSON.stringify(files: options.files, chutes: options.chutes)
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) =>
			return callback(err) if res.statusCode != 200
			body = JSON.parse(body).data
			
			assetIds = [] # pushing asset ids and returning them at the end
			
			assetIds.push(asset.id) for asset in body.existing_assets
			
			async.forEach body.new_assets, (asset, nextAsset) =>
				assetIds.push asset.id
				
				fs.readFile asset.upload_info.file_path, (err, file) ->
					request
						url: asset.upload_info.upload_url
						method: 'PUT'
						headers:
							'Authorization': asset.upload_info.signature
							'Date': asset.upload_info.date
							'Content-Type': asset.upload_info.content_type
							'x-amz-acl': 'public-read'
						body: file # Buffer
					, (err, res, body) -> do nextAsset
			, =>
				request
					url: "http://api.getchute.com/v2/uploads/#{ body.id }/complete"
					method: 'POST'
					headers:
						'x-client_id': @client.options.id
						'Authorization': "OAUTH #{ @client.options.token }"
				, (err, res, body) -> callback err, assetIds

class Chutes
	constructor: (@client) -> # getting link to client and ability to get options
	
	all: (callback) -> # getting all chutes
		request
			url: "http://api.getchute.com/v1/me/chutes"
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
			url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }/assets/add"
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
			url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }/assets/remove"
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
		request
			url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }"
			method: 'GET'
			headers:
				'x-client_id': @client.options.id
				'Authorization': "OAUTH #{ @client.options.token }"
		, (err, res, body) =>
			switch res.statusCode
				when 200
					chute = JSON.parse(body).data
					return callback no, chute if not (options.contributors or options.members or options.parcels)
					
					findContributors = (done) =>
						request
							url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }/contributors"
							method: 'GET'
							headers:
								'x-client_id': @client.options.id
								'Authorization': "OAUTH #{ @client.options.token }"
						, (err, res, body) ->
							chute.contributors = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					findMembers = (done) =>
						request
							url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }/members"
							method: 'GET'
							headers:
								'x-client_id': @client.options.id
								'Authorization': "OAUTH #{ @client.options.token }"
						, (err, res, body) ->
							chute.members = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					findParcels = (done) =>
						request
							url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }/parcels"
							method: 'GET'
							headers:
								'x-client_id': @client.options.id
								'Authorization': "OAUTH #{ @client.options.token }"
						, (err, res, body) ->
							chute.parcels = switch res.statusCode
								when 200 then JSON.parse(body).data
								else []
							
							do done
					
					methods = []
					methods.push findContributors if options.contributors
					methods.push findMembers if options.members
					methods.push findParcels if options.parcels
					
					async.parallel methods, -> callback no, chute
				when 401 then callback 'invalid access token', []
				else callback JSON.parse(body).error, []
	
	create: (options, callback) -> # creating chute, options should be { name: 'Name of the Chute' }
		request
			url: "http://api.getchute.com/v1/chutes"
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
			url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }"
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
			url: "http://api.getchute.com/v1/chutes/#{ options.id or options.shortcut }"
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
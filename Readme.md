# Chute

Chute is obviously API client for [Chute](http://getchute.com).

# Installation

`npm install chute`

# Usage (CoffeeScript)

```coffee-script
Chute = require 'chute'

client = new Chute
client.set token: 'your awesome access token'

client.chutes.all (err, chutes) ->
	# chutes is an array of all chutes

client.chutes.find id: 1354235, (err, chute) ->
	# chute is an object, which contains info about chute with an ID=1354235

client.chutes.create name: 'Just playing around', (err, chute) ->
	# chute is an object, which contains info about our new chute

client.chutes.update name: 'Updating title', id: 1354235, (err, chute) ->
	# chute is an object, which contains info about updated chute

client.chutes.remove id: 1354235, (err) ->
	# chute with ID=1354235 removed

testImage = '/Users/me/Desktop/image.png'

fs = require 'fs'
async = require 'async'

client.parcels.create files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: fs.statSync(testImage).size }], chutes: [1], (err, parcel) ->
	# parcel created
	
	client.parcels.find id: parcel.id, (err, parcel) ->
		# same parcel found

	async.forEach parcel.uploads, (upload, nextUpload) ->
		client.uploads.generateToken id: upload.asset_id, (err, upload) ->
			client.uploads.upload upload, (err) ->
				client.uploads.complete upload, (err) ->
					do nextUpload
	, ->
		# all files are uploaded
```

# Usage (JavaScript)

```javascript
var Chute = require('chute');

var client = new Chute;
client.set({ token: 'your awesome access token' });

client.chutes.all(function(err, chutes){
	// chutes in an array of all chutes
});

client.chutes.find({ id: 1354235 }, function(err, chute){
	// chute is an object, which contains info about chute with an ID=1354235
});

client.chutes.create({ name: 'Just playing around' }, function(err, chute){
	// chute is an object, which contains info about our new chute
});

client.chutes.update({ name: 'Updating title', id: 1354235 }, function(err, chute){
	// chute is an object, which contains info about updated chute
});

client.chutes.remove({ id: 1354235 }, function(err){
	// chute with ID=1354235 removed
});

var testImage = '/Users/me/Desktop/image.png';

var fs = require('fs');
var async = require('async');

client.parcels.create({
	files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: fs.statSync(testImage).size }],
	chutes: [1]
}, function(err, parcel){
	// parcel created
	
	client.parcels.find({ id: parcel.id }, function(err, parcel){
		// same parcel found
	});
	
	async.forEach(parcel.uploads, function(upload, nextUpload){
		client.uploads.generateToken({ id: upload.asset_id }, function(err, upload){
			client.uploads.upload(upload, function(err){
				client.uploads.complete(upload, function(err){
					nextUpload();
				});
			});
		});
	}, function(){
		// all files are uploaded
	});
});
```

# Ideas about improving API

- All responses from API should have the same structure, like:
```json
{
	"code": 12,
	"data": {},
	"success": true
}
```
- If sizes of two files are identical, it does not mean that they are the same. Real md5 must be calculated(POST /parcels)
- Sending correct md5 to *POST /parcels* fails request, while sending exact copy of file's size is ok
# Tests

Run tests with:
`mocha -t 10000`
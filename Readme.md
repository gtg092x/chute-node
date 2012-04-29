# Chute

Chute is obviously API client for [Chute](http://getchute.com).

# Installation

`npm install chute`

# Getting Started

1. Sign Up at [Chute](http://auth.getchute.com/signup?authorization=4f541b8e38ecef3f4d000001)
2. Install this library
3. Read the [API docs](http://explore.picture.io) for better understanding

# Usage (CoffeeScript)

Initialize:

```coffee-script
Chute = require 'chute'
client = new Chute
client.set token: 'access token', id: 'app id', endpoint: 'optional'
```

## Chutes

Find:

```coffee-script
client.chutes.all (err, chutes) -> # all chutes found
	for chute in chutes
		chute.id

client.chutes.find id: 235345, (err, chute) -> # chute with ID=235345 found
	chute.id

client.chutes.find id: 12345, contributors: yes, (err, chute) -> # chute with ID=12345 found with contributors list inside
	chute.contributors

client.chutes.find id: 12345, members: yes, (err, chute) -> # chute with ID=12345 found with members list inside
	chute.members

client.chutes.find id: 12345, parcels: yes, (err, chute) -> # chute with ID=12345 found with parcels list inside
	chute.parcels

client.chutes.find id: 12345, contributors: yes, members: yes, parcels: yes, (err, chute) -> # chute with ID=12345 found with everything inside
	chute.id
```

Create:

```coffee-script
client.chutes.create name: 'Testing', (err, chute) -> # chute created
	chute.id
```

Update:

```coffee-script
client.chutes.update id: 235345, name: 'New name', (err, chute) -> # chute with ID=235345 changed name to 'New name'
	chute.id
```

Remove:

```coffee-script
client.chutes.remove id: 235345, (err) -> # chute with ID=235345 removed
```

## Parcels

Find:

```coffee-script
client.parcels.find id: 12345, (err, parcel) -> # parcel with ID=12345 found
	parcel.id
```

Create:

```coffee-script
files = [{
	filename: 'path/to/image.png',
	size: 123545,
	md5: 123545 # should be the same as size, right now
}]

client.parcels.create files: files, chutes: [12345], (err, parcel) -> # parcel created
	parcel.id
```

## Assets

Find:

```coffee-script
client.assets.find id: 12345, (err, asset) -> # asset with ID=12345 found
	asset.id

client.assets.find id: 12345, comments: yes, (err, asset) -> # asset with ID=12345 found with comments inside
	asset.comments
```

Customize:

```coffee-script
client.assets.find id: 12345, (err, asset) ->
	asset.url.width(640) # http://media.getchute.com/media/:id/w/640
	asset.url.height(480) # http://media.getchute.com/media/:id/h/480
	asset.url.fill(640, 480) # http://media.getchute.com/media/:id/640x480
	asset.url.fit(640, 480) # http://media.getchute.com/media/:id/fit/640x480
```

Like:

```coffee-script
client.assets.heart id: 12345, (err, asset) -> # +1 to asset with ID=12345

client.assets.unheart id: 12345, (err, asset) -> # -1 to asset with ID=12345
```

Remove:

```coffee-script
client.assets.remove id: 12345, (err) -> # asset with ID=12345 removed
```

## Bundles

Find:

```coffee-script
client.bundles.find id: 12345, (err, bundle) -> # bundle with ID=12345 found
	bundle.id
```

Create:

```coffee-script
client.bundles.create ids: [134234, 534125], (err, bundle) -> # bundle with assets 134234 and 534125 created
	bundle.id
```

Remove:

```coffee-script
client.bundles.remove id: 12345, (err) -> # bundle with ID=12345 removed
```

## Uploads

Generate token:

```coffee-script
client.uploads.generateToken id: parcel.uploads[n].asset_id, (err, upload) ->
```

Upload:

```coffee-script
# upload is a variable from previous example

client.uploads.upload upload, (err) ->
	# media uploaded
```

Complete:

```coffee-script
# upload is a variable from previous examples

client.uploads.complete upload, -> # processing of media triggered
```

# Usage (JavaScript)

Initialize:

```javascript
var Chute = require('chute');
var client = new Chute;
client.set({
	token: 'access token',
	id: 'app id, optional',
	endpoint: 'optional'
});
```

## Chutes

Find:

```javascript
client.chutes.all(function(err, chutes){ // all chutes found
	for(var i = 0; i < chutes.length; i++) {
		chute.id;
	}
});

client.chutes.find({ id: 12345 }, function(err, chute){ // chute with ID=12345 found
	chute.id;
});

client.chutes.find({ id: 12345, contributors: true }, function(err, chute){ // chute with ID=12345 found with contributors list inside
	chute.contributors;
});

client.chutes.find({ id: 12345, members: true }, function(err, chute){ // chute with ID=12345 found with members list inside
	chute.members;
});

client.chutes.find({ id: 12345, parcels: true }, function(err, chute){ // chute with ID=12345 found with parcels list inside
	chute.parcels;
});

client.chutes.find({ // chute with ID=12345 found with everything inside
	id: 12345,
	contributors: true,
	members: true,
	parcels: true
}, function(err, chute){
	chute.id;
});
```

Create:

```javascript
client.chutes.create({ name: 'Testing' }, function(err, chute){ // chute created
	chute.id;
});
```

Update:

```javascript
client.chutes.update({ id: 235345, name: 'New name' }, function(err, chute){ // chute with ID=235345 changed name to 'New name'
	chute.id;
});
```

Remove:

```javascript
client.chutes.remove({ id: 12345 }, function(err){ // chute with ID=12345 removed
	
});
```

## Parcels

Find:

```javascript
client.parcels.find({ id: 12345 }, function(err, parcel){ // parcel with ID=12345 found
	parcel.id;
});
```

Create:

```javascript
var files = [{
	filename: 'path/to/image.png',
	size: 123545,
	md5: 123545 // should be the same as size, right now
}];

client.parcels.create({ files: files, chutes: [12345] }, function(err, parcel){
	parcel.id;
});
```

## Assets

Find:

```javascript
client.assets.find({ id: 12345 }, function(err, asset){ // asset with ID=12345 found
	asset.id;
});

client.assets.find({ id: 12345, comments: true }, function(err, asset){ // asset with ID=12345 found with comments inside
	asset.comments;
});
```

Customize:

```javascript
client.assets.find({ id: 12345 }, function(err, asset){
	asset.url.width(640) // http://media.getchute.com/media/:id/w/640
	asset.url.height(480) // http://media.getchute.com/media/:id/h/480
	asset.url.fill(640, 480) // http://media.getchute.com/media/:id/640x480
	asset.url.fit(640, 480) // http://media.getchute.com/media/:id/fit/640x480
});
```

Like:

```javascript
client.assets.heart({ id: 12345 }, function(err, asset){
	// +1 to asset with ID=12345
});

client.assets.unheart({ id: 12345 }, function(err, asset){
	// -1 to asset with ID=12345
});

Remove:

```javascript
client.assets.remove({ id: 12345 }, function(err){
	// asset with ID=12345 removed
});
```

## Bundles

Find:

```javascript
client.bundles.find({ id: 12345 }, function(err, bundle){ // bundle with ID=12345
	bundle.id;
});
```

Create:

```javascript
client.bundles.create({
	ids: [134234, 534125]
}, function(err, bundle){
	// bundle with assets 134234 and 534125 created
});
```

Remove:

```javascript
client.bundles.remove({ id: 12345 }, function(err){
	// bundle with ID=12345 removed
});
```

## Uploads

Generate token:

```javascript
client.uploads.generateToken({ id: parcel.uploads[n].asset_id }, function(err, upload){
	
});
```

Upload:

```javascript
// upload is a variable from previous example

client.uploads.upload(upload, function(err){
	// media uploaded
});
```

Complete:

```javascript
// upload is a variable from previous examples

client.uploads.complete(upload, function(){
	// processing of media triggered
});
```

# Tests

Put your app credentials(access token and id) into test and run it with:
`mocha -t 10000`
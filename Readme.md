# Chute

This package provides a wrapper for the Chute API.  You can learn more about Chute [http://getchute.com](http://getchute.com) and explore the API at [http://picture.io](http://picture.io).

# Installation

`npm install chute`

# Getting Started

1. Sign up at [Chute](http://auth.getchute.com/signup?authorization=4f541b8e38ecef3f4d000001)
2. Install this library
3. Read the [API docs](http://explore.picture.io) for better understanding

# Usage

Initialize:

```javascript
var Chute = require('chute');
var client = new Chute;
client.set({
	token: 'access token',
	id: 'app id, optional'
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
	asset.url // http://media.getchute.com/media/:id
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
```

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

```javascript
var files = [{ filename: 'image.jpg', size: 124235, md5: '0cc175b9c0f1b6a831c399e269772661' }]; // info about files
var chutes = [12423523]; // ID of chute which you want upload image to

client.uploads.upload({ files: files, chutes: chutes }, function(err, assets){
	// assets is an array of asset IDs, which were just uploaded
});
```

# Tests

Put your app credentials(access token and id) into test and run it with:
`mocha --timeout 10000`
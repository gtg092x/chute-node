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
```

# Tests

`mocha`
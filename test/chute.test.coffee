require 'should'
fs = require 'fs'

Chute = require '../'
client = new Chute
client.set token: 'access token', id: 'app id' # fill in your auth credentials

assetId = parcelId = chuteId = bundleId = undefined
testImage = '/Users/me/Desktop/Cat.jpg' # put some test image here

describe 'Chutes', ->
	it 'should create chute', (done) ->
		client.chutes.create name: 'Testing things', (err, chute) ->
			chuteId = chute.id
			err.should.equal(no) and chute.name.should.equal('Testing things')
			do done
	
	it 'should get all chutes', (done) ->
		client.chutes.all (err, chutes) ->
			chutes.length.should.be.above 0
			do done
	
	it 'should get a chute', (done) ->
		client.chutes.find id: chuteId, (err, chute) ->
			err.should.equal no
			do done
	
	it 'should update chute', (done) ->
		client.chutes.update id: chuteId, name: 'Wohoo', (err, chute) ->
			err.should.equal(no) and chute.name.should.equal('Wohoo')
			do done
	
	it 'should find chute\'s contributors', (done) ->
		client.chutes.find id: chuteId, contributors: yes, (err, chute) ->
			err.should.equal(no) and chute.contributors.length.should.equal(0)
			do done
	
	it 'should find chute\'s members', (done) ->
		client.chutes.find id: chuteId, members: yes, (err, chute) ->
			err.should.equal(no) and chute.members.length.should.equal(1)
			do done
	
	it 'should find chute\'s parcels', (done) ->
		client.chutes.find id: chuteId, parcels: yes, (err, chute) ->
			err.should.equal(no) and chute.parcels.length.should.equal(0)
			do done
	
	it 'should remove chute', (done) ->
		client.chutes.remove id: chuteId, (err) ->
			err.should.equal no
			do done

describe 'Uploads', ->
	before (done) ->
		client.chutes.create name: 'Beach', (err, chute) ->
			chuteId = chute.id
			do done
	
	it 'should upload file', (done) ->
		client.uploads.upload files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: require('crypto').createHash('md5').update(fs.readFileSync(testImage, 'utf-8')).digest('hex') }], chutes: [chuteId], (err, assets) ->
			assetId = assets.ids[0]
			do done

describe 'Bundles', ->
	it 'should create a bundle', (done) ->
		client.bundles.create ids: [assetId], (err, bundle) ->
			bundleId = bundle.id
			err.should.equal(no) and bundle.id.should.be.above(0)
			do done
	
	it 'should find a bundle', (done) ->
		client.bundles.find id: bundleId, (err, bundle) ->
			err.should.equal(no)
			do done
	
	it 'should remove bundle', (done) ->
		client.bundles.remove id: bundleId, (err) ->
			err.should.equal(no)
			do done

describe 'Assets', ->
	it 'should find an asset', (done) ->
		client.assets.find id: assetId, (err, asset) ->
			err.should.equal(no) and asset.id.should.equal(assetId)
			do done
	
	it 'should find an asset with comments inside', (done) ->
		client.assets.find chuteId: chuteId, id: assetId, comments: yes, (err, asset) ->
			err.should.equal(no) and asset.comments.length.should.equal(0)
			do done
	
	it 'should heart an asset', (done) ->
		client.assets.heart id: assetId, (err) ->
			err.should.equal(no)
			do done
	
	it 'should unheart an asset', (done) ->
		client.assets.unheart id: assetId, (err) ->
			err.should.equal(no)
			do done
	
	it 'should remove asset', (done) ->
		client.assets.remove id: assetId, (err) ->
			err.should.equal(no)
			do done
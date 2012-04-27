require 'should'
fs = require 'fs'

Chute = require '../lib/chute'
client = new Chute
client.set token: '7b50e3bfce859eeaace42751eece7baaadc5ce4b3fb78afcc2eac73ef98c3e30', id: '4f90692666fd5a0fcb00001a', endpoint: 'http://api.getchute.com/v1'

assetId = parcelId = chuteId = bundleId = undefined
testImage = '/Users/vadimdemedes/Desktop/Flower.jpg'

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
	
	it 'should remove chute', (done) ->
		client.chutes.remove id: chuteId, (err) ->
			err.should.equal no
			do done

describe 'Uploads', ->
	before (done) ->
		client.chutes.create name: 'Flowers', (err, chute) ->
			chuteId = chute.id
			do done
	
	it 'should create parcel and upload files', (done) ->
		client.parcels.create files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: fs.statSync(testImage).size }], chutes: [chuteId], (err, parcel) ->
			assetId = parcel.uploads[0].asset_id
			parcelId = parcel.id
			client.uploads.generateToken id: parcel.uploads[0].asset_id, (err, upload) ->
				client.uploads.upload upload, (err) ->
					client.uploads.complete upload, ->
						do done

describe 'Parcels', ->
	it 'should find a parcel', (done) ->
		client.parcels.find id: parcelId, (err, parcel) ->
			err.should.equal(no) and parcel.id.should.equal parcelId
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
	
	it 'should remove asset', (done) ->
		client.assets.remove id: assetId, (err) ->
			err.should.equal(no)
			do done
require 'should'

Chute = require '../lib/chute'
client = new Chute
client.set token: '', id: '', endpoint: 'http://api.getchute.com/v1'

chuteId = undefined
testImage = '/Users/me/Desktop/image.png'

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
	
	it 'should get chute', (done) ->
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

fs = require 'fs'

parcelId = undefined

describe 'Parcels', ->
	it 'should create parcel', (done) ->
		client.parcels.create files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: crypto.createHash('md5').update(fs.readFileSync(testImage)).digest('hex') }], chutes: [1], (err, parcel) ->
			parcelId = parcel.id
			err.should.equal(no) and parcel.id.should.be.above 0
			do done
	
	it 'should find parcel', (done) ->
		client.parcels.find id: parcelId, (err, parcel) ->
			err.should.equal(no) and parcel.id.should.equal parcelId
			do done
	
describe 'Uploads', ->
	it 'should create parcel and upload files', (done) ->
		client.parcels.create files: [{ filename: testImage, size: fs.statSync(testImage).size, md5: fs.statSync(testImage).size }], chutes: [1], (err, parcel) ->
			client.uploads.generateToken id: parcel.uploads[0].asset_id, (err, upload) ->
				client.uploads.upload upload, (err) ->
					client.uploads.complete upload, ->
						do done
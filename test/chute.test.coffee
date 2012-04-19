require 'should'

Chute = require '../lib/chute'
client = new Chute
client.set token: 'YOUR TOKEN', endpoint: 'http://api.getchute.com/v1'

testId = undefined

describe 'Chute', ->
	describe 'Chutes', ->
		it 'should create chute', (done) ->
			client.chutes.create name: 'Testing things', (err, chute) ->
				testId = chute.id
				err.should.equal(no) and chute.name.should.equal('Testing things')
				do done
		
		it 'should get all chutes', (done) ->
			client.chutes.all (err, chutes) ->
				chutes.length.should.be.above 0
				do done
		
		it 'should get chute', (done) ->
			client.chutes.find id: testId, (err, chute) ->
				err.should.equal no
				do done
		
		it 'should update chute', (done) ->
			client.chutes.update id: testId, name: 'Wohoo', (err, chute) ->
				err.should.equal(no) and chute.name.should.equal('Wohoo')
				do done
		
		it 'should remove chute', (done) ->
			client.chutes.remove id: testId, (err) ->
				err.should.equal no
				do done
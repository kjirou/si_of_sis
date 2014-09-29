request = require 'supertest'

app = require 'app'


describe 'core Application', ->

  it 'GET /', (done) ->
    request(app).get('/').expect(200).end done


  describe 'passport Authentication', ->

    it 'passport', (done) ->
      request(app).get('/?username=1&password=2').expect(200).end done

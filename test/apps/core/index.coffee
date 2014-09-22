request = require 'supertest'

app = require 'apps/app'


describe 'core Application', ->

  it 'GET /', (done) ->
    request(app).get('/').expect(200).end done

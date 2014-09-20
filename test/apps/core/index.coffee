request = require 'supertest'

app = require 'apps/app'


describe 'core Application', ->

  it 'GET /', ->
    request(app).get('/').expect 200

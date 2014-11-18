async = require 'async'
express = require 'express'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'


describe 'express-3.x Vendor', ->

  it 'res.jsonとjsonpで返す値にundefinedが含まれていた場合はキーが削除される', (done) ->
    app = express()
    app.get '/json', (req, res, next) ->
      res.json
        x: null
        y: undefined
        nested:
          a: null
          b: undefined
    app.get '/jsonp', (req, res, next) ->
      res.json
        x: null
        y: undefined
        nested:
          a: null
          b: undefined

    async.series [
      (next) ->
        request app
          .get '/json'
          .expect 200
          .end (e, res) ->
            return next e if e
            assert.deepEqual JSON.parse(res.text),
              x: null
              nested:
                a: null
            next()
      (next) ->
        request app
          .get '/jsonp'
          .expect 200
          .end (e, res) ->
            return next e if e
            assert.deepEqual JSON.parse(res.text),
              x: null
              nested:
                a: null
            next()
    ], done

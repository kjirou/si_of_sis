async = require 'async'
chain = require 'connect-chain'
express = require 'express'
assert = require 'power-assert'
request = require 'supertest'

{Http404Error} = require 'lib/errors'
httpMiddleware = require 'lib/middlewares/http'
{allow, getOnly, postOnly} = httpMiddleware


describe 'http Middleware', ->

  it 'allow', (done) ->
    controller = (req, res, next) -> next()
    chained = chain allow(methods:['GET']), controller
    chained {method:'GET'}, {}, (e) ->
      assert not e
      chained {method:'POST'}, {}, (e) ->
        assert e instanceof Error
        assert e.name is 'Http404Error'
        assert /POST/.test e.message
        done()

  it 'getOnly, postOnly', (done) ->
    controller = (req, res, next) -> next()
    getOnlyController = chain getOnly(), controller
    postOnlyController = chain postOnly(), controller

    async.series [
      (next) -> getOnlyController {method:'GET'}, {}, next
      (next) -> postOnlyController {method:'POST'}, {}, next
      (next) -> getOnlyController {method:'POST'}, {}, (e) ->
        assert e instanceof Error
        next()
      (next) -> postOnlyController {method:'GET'}, {}, (e) ->
        assert e instanceof Error
        next()
    ], done

  it 'expressと連携できる', (done) ->
    app = express()
    app.all '/get_only', allow(methods:['GET']), (req, res, next) ->
      res.send 'Success'
    app.all '/post_only', allow(methods:['POST']), (req, res, next) ->
      res.send 'Success'
    app.all '/another_get_only', getOnly(), (req, res, next) ->
      res.send 'Success'
    async.series [
      (nextStep) ->
        request app
          .get '/get_only'
          .expect 200
          .end nextStep
      (nextStep) ->
        request app
          .post '/get_only'
          .expect 500
          .end nextStep
      (nextStep) ->
        request app
          .post '/post_only'
          .expect 200
          .end nextStep
      (nextStep) ->
        request app
          .post '/get_only'
          .expect 500
          .end nextStep
      (nextStep) ->
        request app
          .get '/another_get_only'
          .expect 200
          .end nextStep
      (nextStep) ->
        request app
          .post '/another_get_only'
          .expect 500
          .end nextStep
    ], done

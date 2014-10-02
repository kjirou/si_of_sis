assert = require 'power-assert'
express = require 'express'
request = require 'supertest'

{Http404Error} = require 'lib/errors'
authenticationMiddleware = require 'lib/middlewares/authentication'


describe 'authentication Middleware', ->

  it 'requireUser', ->
    middleware = authenticationMiddleware.requireUser()
    middleware {user:{}}, {}, (e) ->
      assert not e
      middleware {}, {}, (e) ->
        assert(e instanceof Http404Error)

  it 'requireUserでリダイレクト先を設定できる', (done) ->
    app_ = express()
    app_.get '/', (req, res, next) -> res.end()
    app_.get '/mypage', authenticationMiddleware.requireUser(redirectTo:'/'), (req, res, next) -> res.end()
    request(app_).get('/').expect 200, (e) ->
      return done e if e
      request(app_).get('/mypage').expect(302, done)

  it 'requireLogin', (done) ->
    app_ = express()
    app_.get '/login', (req, res, next) -> res.end()
    app_.get '/mypage', authenticationMiddleware.requireLogin(), (req, res, next) -> res.end()
    request(app_).get('/login').expect 200, (e) ->
      return done e if e
      request(app_).get('/mypage').expect(302, done)

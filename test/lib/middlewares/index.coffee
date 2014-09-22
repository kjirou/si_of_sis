assert = require 'assert'

middlewares = require 'lib/middlewares'


describe 'middlewares Lib', ->

  describe 'createSubAppMiddleware', ->

    it 'ミドルウェアを生成でき、その適用により各プロパティが設定できる', ->
      mw = middlewares.createSubAppMiddleware 'foo'
      assert typeof mw is 'function'
      [req, res, next] = [{}, {}, -> ]
      mw req, res, next
      assert typeof req.subApp is 'object'
      assert req.subApp.name is 'foo'
      assert typeof res.renderSubApp is 'function'

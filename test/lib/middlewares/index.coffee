async = require 'async'
{Model, Schema} = require 'mongoose'
assert = require 'power-assert'


databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'
middlewares = require 'lib/middlewares'


describe 'middlewares Lib', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it 'createSubAppMiddleware', ->
    mw = middlewares.createSubAppMiddleware 'foo'
    assert typeof mw is 'function'
    [req, res, next] = [{}, {}, -> ]
    mw req, res, next
    assert typeof req.subApp is 'object'
    assert req.subApp.name is 'foo'
    assert typeof res.renderSubApp is 'function'


  it 'createDocIdMiddleware', (done) ->
    testHelper.createTestModel new Schema, (e, Test) ->
      mw = middlewares.createDocIdMiddleware Test
      assert typeof mw is 'function'
      # テスト用に予め 2 docs 作成する
      ids = (testHelper.createUniqueObjectId() for i in [0..1])
      async.each ids, (id, nextLoop) ->
        doc = new Test
        doc._id = id
        doc.save nextLoop
      , (e) ->
        Test.find (e, docs) ->
          assert docs.length is 2
          # ミドルウェアの機能で doc を自動取得できる
          req = {params:{id:ids[0].toString()}}
          mw req, {}, (e) ->
            assert req.doc instanceof Model
            assert req.doc._id.toString() is ids[0].toString()
            # もうひとつの id でも取得できる
            req.params.id = ids[1]
            mw req, {}, (e) ->
              assert req.doc instanceof Model
              assert req.doc._id.toString() is ids[1].toString()
              # undefined など null
              req.params.id = undefined
              mw req, {}, (e) ->
                assert req.doc is null
                done()

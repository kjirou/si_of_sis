async = require 'async'
{Model, Schema} = require 'mongoose'
assert = require 'power-assert'

databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'
{Http404Error} = require 'lib/errors'
coreMiddleware = require 'lib/middlewares/core'


describe 'core Middleware', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it 'applySubAppData', ->
    mw = coreMiddleware.applySubAppData 'foo'
    assert typeof mw is 'function'
    [req, res, next] = [{}, {}, -> ]
    mw req, res, next
    assert typeof req.subApp is 'object'
    assert req.subApp.name is 'foo'
    assert typeof res.subApp.render is 'function'


  it 'applyObjectId', (done) ->
    testHelper.createTestModel new Schema, (e, Test) ->
      mw = coreMiddleware.applyObjectId Test
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
              # ObjectId として不正なものは null
              req.params.id = undefined
              mw req, {}, (e) ->
                assert req.doc is null
                # 正しい ObjectId だがデータが存在しない :id
                req.params.id = testHelper.createUniqueObjectId()
                mw req, {}, (e) ->
                  assert req.doc is null
                  done()

  it 'requireObjectId', (done) ->
    testHelper.createTestModel new Schema, (e, Test) ->
      middleware = coreMiddleware.requireObjectId Test
      # :id が存在しない
      middleware {params:{}}, {}, (e) ->
        assert e instanceof Http404Error
        # 正しい :id だがデータが存在しない
        id = testHelper.createUniqueObjectId()
        middleware {params:{id:id}}, {}, (e) ->
          assert e instanceof Http404Error
          done()

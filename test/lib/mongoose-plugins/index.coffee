assert = require 'assert'
mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
_ = require 'underscore'

databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'
{plugins, getPlugins} = require 'lib/mongoose-plugins'


describe 'mongoose-plugins Lib', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it 'baseQueries Plugin', (done) ->
    schema = new Schema
    schema.plugin plugins.baseQueries
    testHelper.createTestModel schema, (e, Test) ->
      return done e if e
      # プラグインで付与したメソッドがある
      assert Test.queryOneById typeof 'function'
      # _id を固定にして 1 行保存する
      objectId = ObjectId ('0' for i in [0..23]).join('')
      testObj = _.extend new Test, { _id:objectId }
      testObj.save (e) ->
        # その 1 行を findOneById で取得できる
        Test.findOneById objectId, (e, doc) ->
          return done e if e
          assert doc
          assert doc._id.toString() is objectId.toString()
          # 不正な _id 文字列指定の場合は null を返す
          Test.findOneById 'invalid_object_id', (e, doc) ->
            return done e if e
            assert doc is null
            done()

  it 'getPlugins', (done) ->
    schema = new Schema
    schema.plugin getPlugins()
    testHelper.createTestModel schema, (e, Test) ->
      assert Test.queryOneById typeof 'function'
      done()

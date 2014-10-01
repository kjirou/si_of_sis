assert = require 'power-assert'
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

  it 'createdAt Plugin', (done) ->
    schema = new Schema
    schema.plugin plugins.createdAt
    testHelper.createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        return done e if e
        # 保存元オブジェクトにも設定されている
        assert doc.created_at instanceof Date
        Test.findOne (e, doc_) ->
          return done e if e
          # 再抽出したドキュメントにも保存されている
          assert doc_.created_at instanceof Date
          # 保存時と同じ時間である
          assert doc_.created_at.getTime() is doc.created_at.getTime()
          # 50ms 後に再抽出して更新しても created_at は更新されていない
          setTimeout ->
            Test.findOne {_id:doc_._id}, (e, doc__) ->
              return done e if e
              doc__.save (e) ->
                return done e if e
                assert doc__.created_at.getTime() is doc_.created_at.getTime()
                done()
          , 50

  it 'updatedAt Plugin', (done) ->
    schema = new Schema
    schema.plugin plugins.updatedAt
    testHelper.createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        # 保存元オブジェクトにも設定されている
        assert doc.updated_at instanceof Date
        Test.findOne (e, doc_) ->
          return done e if e
          # 再抽出したドキュメントにも保存されている
          assert doc_.updated_at instanceof Date
          # 保存時と同じ時間である
          assert doc_.updated_at.getTime() is doc.updated_at.getTime()
          # 50ms 後に再抽出して更新すると時間が進んでいる
          setTimeout ->
            Test.findOne {_id:doc_._id}, (e, doc__) ->
              return done e if e
              doc__.save (e) ->
                return done e if e
                assert doc__.updated_at.getTime() > doc_.updated_at.getTime()
                done()
          , 50

  it 'createdAt/updatedAtが連携している', (done) ->
    schema = new Schema
    schema.plugin plugins.createdAt
    schema.plugin plugins.updatedAt
    testHelper.createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        return done e if e
        # 保存元オブジェクトには時間が両方設定され、オブジェクトの参照も同じである
        assert doc.created_at instanceof Date
        assert doc.updated_at instanceof Date
        assert doc.created_at is doc.updated_at
        # 50ms 後に再抽出して更新するとupdated_atのみに変更がある
        setTimeout ->
          Test.findOne (e, doc_) ->
            return done e if e
            doc_.save (e) ->
              return done e if e
              assert doc_.updated_at.getTime() > doc_.created_at.getTime()
              done()
        , 50

  it 'getPlugins', (done) ->
    schema = new Schema
    schema.plugin getPlugins()
    testHelper.createTestModel schema, (e, Test) ->
      assert Test.queryOneById typeof 'function'
      done()

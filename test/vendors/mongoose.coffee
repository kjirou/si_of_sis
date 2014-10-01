assert = require 'assert'
async = require 'async'
mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
_ = require 'underscore'

{Sandbox} = require 'apps/core/models'
databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'


describe 'mongoose Vendor', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it '同ObjectIdでsaveされた場合エラーになる', (done) ->
    # 同プロセス内では new によるドキュメント生成時にユニークな _id が振られるので重複しない。
    # しかし、複数のアプリサーバを建てた場合はこの限りではなくなる。
    # テストも別プロセスでやるべきだが、とりあえずは同プロセスでテストする。
    sandbox = new Sandbox
    id = sandbox._id
    assert id instanceof ObjectId
    sandbox.save (e) ->
      return done e if e
      sandbox_ = new Sandbox
      sandbox_._id = id
      sandbox_.save (e) ->
        # このようなエラーが出る:
        #
        #   Uncaught MongoError: insertDocument :: caused by :: 11000 E11000 duplicate key error index:
        #   sos_test.sandboxes.$_id_  dup key: { : ObjectId('542524f2f08d6a781ae3f9a9') }
        #
        # なお、素の MongoDB の db.coll.save は上書き更新になる
        assert e.name is 'MongoError'
        done()

  it 'Model.ensureIndexesはインデックスに失敗するとエラーを返す', (done) ->
    testHelper.createTestModel new Schema({
      x:
        type: String
        index:
          unique: true
    }, {
      autoIndex: false
    }), (e, Test) ->
      Test.collection.getIndexes (e, indexes) ->
        # インデックスが張られていないことを確認
        assert _.size(indexes) is 0
        task = (nextStep) ->
          testDoc = new Test
          testDoc.x = 'foo'
          testDoc.save nextStep
        async.parallel [task,task], (e) ->
          return done e if e
          Test.find({x:'foo'}).count (e, count) ->
            return done e if e
            # x = 'foo' が重複している
            assert count is 2
            Test.ensureIndexes (e) ->
              # エラーを返す
              # 11000 の定義は何故か資料が見つからなかった、詳細不明
              assert e.name is 'MongoError'
              assert e.code is 11000
              done()

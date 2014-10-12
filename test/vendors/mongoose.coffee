async = require 'async'
mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
assert = require 'power-assert'
_ = require 'underscore'

databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'


describe 'mongoose Vendor', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it '同ObjectIdでsaveされた場合エラーになる', (done) ->
    # 同プロセス内では new によるドキュメント生成時にユニークな _id が振られるので重複しない。
    # しかし、複数のアプリサーバを建てた場合はこの限りではなくなる。
    # テストも別プロセスでやるべきだが、とりあえずは同プロセスでテストする。
    testHelper.createTestModel new Schema, (e, Test) ->
      return done e if e
      doc = new Test
      id = doc._id
      assert id instanceof ObjectId
      doc.save (e) ->
        return done e if e
        test_ = new Test
        test_._id = id
        test_.save (e) ->
          # このようなエラーが出る:
          #
          #   Uncaught MongoError: insertDocument :: caused by :: 11000 E11000 duplicate key error index:
          #   db_name.coll_name.$_id_  dup key: { : ObjectId('542524f2f08d6a781ae3f9a9') }
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

  it 'pre(\'save\')を複数回設定できる', (done) ->
    steps = []
    schema = new Schema {
      x: String
    }
    schema.pre 'save', (callback) ->
      steps.push 1
      callback()
    schema.pre 'save', (callback) ->
      steps.push 2
      callback()
    schema.pre 'save', (callback) ->
      steps.push 3
      callback()
    testHelper.createTestModel schema, (e, Test) ->
      return done e if e
      assert.deepEqual [], steps
      (new Test).save (e) ->
        return done e if e
        assert.deepEqual [1, 2, 3], steps
        done()

  it 'save後に渡されるdocオブジェクトはsave前のものの参照である', (done) ->
    testHelper.createTestModel new Schema({
      x: Date
    }), (e, Test) ->
      doc = new Test
      doc.x = new Date
      doc.save (e, savedDoc) ->
        assert doc is savedDoc
        assert doc._id is savedDoc._id
        assert doc.x is savedDoc.x
        done()

  it 'Modelオブジェクトへ特異プロパティを設定できる', (done) ->
    testHelper.createTestModel new Schema({
      x: Number
    }), (e, Test) ->
      doc = new Test
      doc.x = 1
      doc.y = 2
      assert.strictEqual doc.x, 1
      assert.strictEqual doc.y, 2
      done()

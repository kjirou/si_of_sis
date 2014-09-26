assert = require 'assert'
{ObjectId} = require('mongoose').Types

{Sandbox} = require 'apps/core/models'


describe 'mongoose Vendor', ->

  it '同ObjectIdでsaveされた場合エラーになる', (done) ->
    # 同プロセス内では new によるドキュメント生成時にユニークな _id が振られるので重複しない。
    # しかし、複数のアプリサーバを建てた場合はこの限りではなくなる。
    # テストも別プロセスでやるべきだが、とりあえずは同プロセスでテストする。
    sandbox = new Sandbox
    id = sandbox._id
    assert id instanceof ObjectId
    sandbox.save (e) ->
      throw e if e
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

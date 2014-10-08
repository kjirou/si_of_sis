conf = require 'conf'
assert = require 'power-assert'


describe 'conf Module', ->

  describe 'conf.session', ->

    before ->
      # セッションデータのモックを作成する
      # connect-mongo の実装を見たら、オブジェクトなら何でも良さそうだった
      @createSessionMock = -> {foo:'foo', bar:'bar'}

    it 'MongoDBセッションストレージへ接続できる', ->
      store = conf.session.mongodbStore.createStore()
      store.length()  # 接続失敗時はランタイムエラーになる

    it '同じMongoDBセッションストレージへ複数のインスタンスから接続できる', (done) ->
      self = @
      store1 = conf.session.mongodbStore.createStore()
      store2 = conf.session.mongodbStore.createStore()

      # DB が空なことを確認
      store1.clear (e) ->
        store2.clear (e) ->
          store1.length (e, count) ->
            assert count is 0
            store2.length (e, count) ->
              assert count is 0
              # store1 へデータを1行追加
              sid = 'sid_1'
              sessionData = self.createSessionMock()
              store1.set sid, sessionData, (e) ->
                # store1 へ追加されている
                store1.length (e, count) ->
                  assert count is 1
                  # store2 へも追加されている
                  store2.length (e, count) ->
                    assert count is 1
                    done()

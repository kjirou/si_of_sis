http = require 'http'
assert = require 'power-assert'
request = require 'supertest'
_ = require 'underscore'

app = require 'app'
{User} = require 'apps/user/models'
conf = require 'conf'


describe 'app Module', ->

  describe 'Server', ->

    it 'Webアプリケーションサーバを起動できる', (done) ->
      # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
      server = http.createServer(app).listen conf.server.port, (e) ->
        return done e if e
        server.close (e) ->
          return done e if e
          done()

    it '静的ファイルへリクエストできる', (done) ->
      # robots.txt を代表にする
      request(app).get('/robots.txt').expect(200).end done

    # 手動ではテスト済み、ルートを app から削除する方法がわからなかった
    it 'アプリのルート設定が静的ファイルパスによるルート設定より優先される'


  describe 'Login', ->

    before ->
      self = @
      @defaultParams =
          email: 'foo@example.com'
          password: 'test1234'
      @prepareAndFindUser = (callback) ->
        user = _.extend new User, email:self.defaultParams.email
        user.setPassword self.defaultParams.password
        user.save (e) ->
          return callback e if e
          User.findOneById user._id, (e, user) ->
            return callback e if e
            callback null, user

      # セッションデータの先頭 1 データを取得し返す
      @getSessionData = (callback) ->
        @sessionStore._get_collection (coll) ->
          coll.findOne (e, sess) ->
            return callback e if e
            session = JSON.parse sess.session
            callback null, session

      @sessionStore = conf.session.mongodbStore.prepareConnection()

    beforeEach (done) ->
      @sessionStore.clear (e) ->
        return done e if e
        User.remove done

    it 'ユーザーがPOSTでログインできる', (done) ->
      self = @
      @prepareAndFindUser (e, user) ->
        return done e if e
        request(app)
          .post '/login'
          .send self.defaultParams
          .expect 200
          .end ->
            self.sessionStore.length (e, count) ->
              self.getSessionData (e, session) ->
                assert user._id.toString() is session.passport?.user
                # この位置にあるのは、稀にテストが落ちることがあるため。Ref) #98
                # 他の部分が正しいのかを先にチェックする
                assert count is 1
                done()

    it 'GETリクエストだとログイン出来ない', (done) ->
      self = @
      @prepareAndFindUser (e, user) ->
        return done e if e
        request(app)
          .get '/login'
          .send self.defaultParams
          .expect 200
          .end ->
            self.sessionStore.length (e, count) ->
              assert count is 1
              self.getSessionData (e, session) ->
                assert session.passport.user is undefined
                done()

    it '誤ったデータだとログインが失敗する', (done) ->
      self = @
      @prepareAndFindUser (e, user) ->
        return done e if e
        request(app)
          .post '/login'
          .send(_.extend {}, self.defaultParams, {
            email: 'bar@example.com'
          })
          .expect 200
          .end ->
            self.sessionStore.length (e, count) ->
              assert count is 1
              self.getSessionData (e, session) ->
                assert session.passport.user is undefined
                done()

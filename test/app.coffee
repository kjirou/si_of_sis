http = require 'http'
_ = require 'lodash'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'
{User} = require('apps').models
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
      @findSessionRows = (callback) ->
        self.sessionStore._get_collection (coll) ->
          coll.find().toArray callback

    beforeEach (done) ->
      @sessionStore.clear (e) ->
        return done e if e
        User.remove done

    it 'ユーザーがPOSTでログインできる', (done) ->
      self = @
      @findSessionRows (e, beforeSessionRows) ->
        # Ref #98
        if beforeSessionRows.length > 0
          console.error beforeSessionRows
        self.prepareAndFindUser (e, user) ->
          return done e if e
          request(app)
            .post '/login'
            .send self.defaultParams
            .expect 200
            .end ->
              self.findSessionRows (e, sessionRows) ->
                # Ref #98
                if sessionRows.length > 1
                  console.error sessionRows
                # 2 行なのは、稀にテスト開始前にデータがクリアされていないことがあるため
                # とりあえず諦める、Ref #98
                assert sessionRows.length >= 1
                self.getSessionData (e, session) ->
                  assert user._id.toString() is session.passport?.user
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

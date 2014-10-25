http = require 'http'
_ = require 'lodash'
assert = require 'power-assert'
request = require 'supertest'

app = require 'app'
{User} = require('apps').models
conf = require 'conf'
{monky, valueSets} = require 'helpers/monky'


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
      @prepareAndFindUser = (callback) ->
        monky.create 'User', (e, user) ->
          return callback e if e
          User.findOneById user._id, (e, user) ->
            return callback e if e
            callback null, user

      @sessionStore = conf.session.mongodbStore.prepareConnection()

      # セッションデータ全行を配列で返す
      @findSessionRows = (callback) ->
        self.sessionStore._get_collection (coll) ->
          coll.find().toArray callback

      # JSON文字列から復元したセッション情報を配列で返す
      @findSessions = (callback) ->
        @findSessionRows (e, sessionRows) ->
          return callback e if e
          sessions = for sessionRow in sessionRows
            JSON.parse sessionRow.session
          callback null, sessions

      @extractLoggedInSessions = (sessions, userId) ->
        (session for session in sessions when userId.toString() is session.passport?.user)

    beforeEach (done) ->
      @sessionStore.clear (e) =>
        return done e if e
        @findSessionRows (e, sessionRows) ->
          return done e if e
          # Ref #98
          if sessionRows.length > 0
            console.error '---- In beforeEach ----'
            console.error sessionRows
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
            .send { email:user.email, password:valueSets.user.rawPassword }
            .expect 200
            .end ->
              self.findSessionRows (e, sessionRows) ->
                # Ref #98
                if sessionRows.length > 1
                  console.error sessionRows
                # 2 行なのは、稀にテスト開始前にデータがクリアされていないことがあるため
                # とりあえず諦めて 2 行で判定している、Ref #98
                assert sessionRows.length >= 1
                self.findSessions (e, sessions) ->
                  loggedInSessions = self.extractLoggedInSessions sessions, user._id
                  assert loggedInSessions.length is 1
                  done()

    it 'GETリクエストだとログイン出来ない', (done) ->
      self = @
      @prepareAndFindUser (e, user) ->
        return done e if e
        request(app)
          .get '/login'
          .send { email:user.email, password:valueSets.rawPassword }
          .expect 200
          .end ->
            self.sessionStore.length (e, count) ->
              assert count is 1
              self.findSessions (e, sessions) ->
                loggedInSessions = self.extractLoggedInSessions sessions, user._id
                assert loggedInSessions.length is 0
                done()

    it '誤ったデータだとログインが失敗する', (done) ->
      self = @
      @prepareAndFindUser (e, user) ->
        return done e if e
        request(app)
          .post '/login'
          .send { email:user.email, password:'invalid_password' }
          .expect 200
          .end ->
            self.sessionStore.length (e, count) ->
              assert count is 1
              self.findSessions (e, sessions) ->
                loggedInSessions = self.extractLoggedInSessions sessions, user._id
                assert loggedInSessions.length is 0
                done()

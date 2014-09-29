http = require 'http'
request = require 'supertest'

app = require 'app'
conf = require 'conf'


describe 'app Module', ->

  describe 'Server', ->

    it 'Webアプリケーションサーバを起動できる', (done) ->
      # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
      server = http.createServer(app).listen conf.server.port, (e) ->
        throw e if e
        server.close (e) ->
          throw e if e
          done()

    it '静的ファイルへリクエストできる', (done) ->
      # robots.txt を代表にする
      request(app).get('/robots.txt').expect(200).end done

    # 手動ではテスト済み、ルートを app から削除する方法がわからなかった
    it 'アプリのルート設定が静的ファイルパスによるルート設定より優先される'

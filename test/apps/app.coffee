app = require 'apps/app'
conf = require 'conf'


describe 'app Module', ->

  it 'Webアプリケーションサーバを起動できる', (done) ->
    # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
    server = app.listen conf.server.port, (err) ->
      throw err if err
      server.close (err) ->
        throw err if err
        done()

app = require 'apps/app'
config = require 'config'


describe 'app Module', ->

  it 'Webアプリケーションサーバを3000番ポートで動かせる', (done) ->
    # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
    server = app.listen config.server.port, (err) ->
      throw err if err
      server.close (err) ->
        throw err if err
        done()

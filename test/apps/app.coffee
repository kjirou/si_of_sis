app = require 'apps/app'


describe 'app Module', ->

  it 'Webアプリケーションサーバを3000番ポートで動かせる', (done) ->
    # @TODO listen でエラーを出す方法が不明でエラー時の動作確認してない
    app.listen 3000, (err) ->
      throw err if err
      done()

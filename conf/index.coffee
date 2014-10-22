express = require 'express'
MongoStore = require('connect-mongo')(express)
mongoose = require 'mongoose'
path = require 'path'
wantit = require 'wantit'


mongodbConf =
  host: 'localhost'
  port: '27017'
  databaseName: 'sos'
  user: ''
  pass: ''
  prepareConnections: ->
    uri = "mongodb://#{mongodbConf.host}:#{mongodbConf.port}/#{mongodbConf.databaseName}"
    mongoose.connect uri, {
      user: mongodbConf.user
      pass: mongodbConf.pass
    }, (e) ->
      throw e if e

sessionMongoDbStoreConf =
  host: mongodbConf.host
  port: mongodbConf.port
  databaseName: 'sos_session'
  user: mongodbConf.user
  pass: mongodbConf.pass
  clearInterval: 3600
  prepareConnection: ->
    new MongoStore {
      host: sessionMongoDbStoreConf.host
      port: sessionMongoDbStoreConf.port
      db: sessionMongoDbStoreConf.databaseName
      username: sessionMongoDbStoreConf.user
      password: sessionMongoDbStoreConf.pass
      clear_interval: sessionMongoDbStoreConf.clearInterval
    }


conf =
  auth:
    hmacSecretKey: 'default_secret_key'
  debug: true
  env: express().get 'env'
  mongodb: mongodbConf
  root: path.resolve process.env.NODE_PATH
  server:
    # true=ログを全く出力しない、false=全リクエストを出力、
    #   null=デフォルト（静的ファイルは拡張子で除外など）に従う
    logFiltering: null
    # morgan 準拠でログ書式を設定する、デフォルトは env 依存で変わる
    logFormatType: null
    port: '3000'
  session:
    secret: 'default_session_secret_key'
    mongodbStore: sessionMongoDbStoreConf


wantit('conf/_' + conf.env)?(conf)


module.exports = conf

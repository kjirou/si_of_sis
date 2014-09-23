express = require 'express'
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


conf =
  auth:
    hmacSecretKey: 'default_secret_key'
  debug: true
  env: express().get 'env'
  mongodb: mongodbConf
  root: path.resolve process.env.NODE_PATH
  server:
    port: '3000'


wantit('conf/_' + conf.env)?(conf)


module.exports = conf

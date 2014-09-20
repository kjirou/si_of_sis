express = require 'express'
mongoose = require 'mongoose'
path = require 'path'

coreUtil = require 'lib/util/core'


mongodbConfig =
  host: 'localhost'
  port: '27017'
  databaseName: 'sos'
  user: ''
  pass: ''
  prepareConnections: ->
    uri = "mongodb://#{mongodbConfig.host}:#{mongodbConfig.port}/#{mongodbConfig.databaseName}"
    mongoose.connect uri, {
      user: mongodbConfig.user
      pass: mongodbConfig.pass
    }, (e) ->
      throw e if e


config =
  debug: true
  env: express().get 'env'
  root: path.resolve process.env.NODE_PATH
  mongodb: mongodbConfig


coreUtil.want('config/_' + config.env)?(config)


module.exports = config

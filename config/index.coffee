path = require 'path'
express = require 'express'


config =
  debug: true
  env: express().get 'env'
  root: path.resolve process.env.NODE_PATH

try
  require('config/_' + config.env)(config)
catch e
  unless e.code is 'MODULE_NOT_FOUND'
    throw e

module.exports = config

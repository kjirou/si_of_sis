path = require 'path'
express = require 'express'


config =
  debug: true
  env: express().get 'env'
  root: path.resolve process.env.NODE_PATH

module.exports = config

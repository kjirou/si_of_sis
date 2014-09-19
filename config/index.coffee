path = require 'path'
express = require 'express'


config = module.exports =
  debug: true
  env: express().get 'env'
  root: path.resolve process.env.NODE_PATH

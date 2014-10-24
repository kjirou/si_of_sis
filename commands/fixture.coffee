async = require 'async'
minimist = require 'minimist'
mongoose = require 'mongoose'

{Business} = require('apps').models
{monky} = require 'helpers/monky'


execute = (callback) ->

  parsed = minimist process.argv.slice(3),
    default:
      d: false
    alias:
      d: 'development'

  inputs =
    # 開発環境用のデータを設定する
    development: parsed.development

  async.waterfall [
    # Businesses
    (nextStep, err) ->
      return nextStep() unless inputs.development
      async.times 100, (n, nextLoop) ->
        monky.create 'FakeBusiness', nextLoop
      , nextStep
  ], (e) ->
    callback e


module.exports =
  execute: execute

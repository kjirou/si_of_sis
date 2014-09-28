async = require 'async'
minimist = require 'minimist'
mongoose = require 'mongoose'

{User} = require 'apps/user/models'


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
    (nextStep, err) ->
      return nextStep() unless inputs.development
      dataList = [{
        email: 'dev@example.com'
        rawPassword: 'testtest'
      }]
      async.eachSeries dataList, (data, nextLoop) ->
        user = new User
        user.email = data.email
        user.setPassword data.rawPassword
        user.save (e) ->
          throw e if e
          console.log "Created a user: email=`#{data.email}`"
          nextLoop()
      , (e) ->
        return nextStep e if e
        nextStep()
  ], (e) ->
    callback e


module.exports =
  execute: execute

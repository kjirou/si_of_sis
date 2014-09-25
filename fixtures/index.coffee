async = require 'async'
mongoose = require 'mongoose'
_ = require 'underscore'

{User} = require 'apps/user/models'
{generateHashedPassword} = require 'lib/util/crypto'


execute = ({
  isForDevelopment
}) ->
  bucket = {}

  async.waterfall [
    # 開発環境用の初期データ
    (nextStep, err) ->
      return nextStep() unless isForDevelopment
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
        throw e if e
        nextStep()
  ], (e) ->
    throw e if e
    mongoose.disconnect ->
      process.exit 0


module.exports =
  execute: execute

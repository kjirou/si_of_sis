colo = require 'colo'
minimist = require 'minimist'
mongoose = require 'mongoose'
_ = require 'underscore'
wantit = require 'wantit'


exit = (statusCode=0) ->
  mongoose.disconnect ->
    process.exit statusCode

execute = ->
  options = minimist process.argv.slice(2)
  subCommandName = options._[0] ? 'default'
  subCommand = wantit 'commands/_' + subCommandName
  if subCommand
    subCommand.execute (e) ->
      throw e if e
      exit()
  else
    console.error colo.red "Not found `#{subCommandName}` sub command"
    exit 1


module.exports =
  execute: execute

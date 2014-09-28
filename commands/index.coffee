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
  subCommand = wantit "commands/#{subCommandName}"
  if subCommand
    console.log colo.blue "Start `#{subCommandName}`"
    subCommand.execute (e) ->
      if e
        console.log colo.red "Error is occured in `#{subCommandName}`"
        console.error e.stack or error
        exit 1
      else
        console.log colo.blue "Finish `#{subCommandName}`"
        exit()
  else
    console.error colo.red "Not found `#{subCommandName}` sub command"
    exit 1


module.exports =
  execute: execute

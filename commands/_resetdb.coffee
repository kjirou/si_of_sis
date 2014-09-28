mongoose = require 'mongoose'

databaseHelper = require 'helpers/database'


execute = (onFinishCommand) ->
  databaseHelper.resetDatabase onFinishCommand


module.exports =
  execute: execute

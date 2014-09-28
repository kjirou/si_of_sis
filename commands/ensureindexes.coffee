mongoose = require 'mongoose'

databaseHelper = require 'helpers/database'


execute = (onFinishCommand) ->
  databaseHelper.ensureModelIndexes onFinishCommand


module.exports =
  execute: execute

apps = require 'apps'
mongodbUtil = require 'lib/util/mongodb'


helper = {}

helper.resetDatabase = (callback) ->
  mongodbUtil.purgeDatabase (e) ->
    throw e if e
    apps.ensureModelIndexes callback


module.exports = helper

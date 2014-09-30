async = require 'async'
_ = require 'underscore'

apps = require 'apps'
mongodbUtil = require 'lib/util/mongodb'


helper = {}

# 全 Model のインデックスを再生成する
helper.ensureModelIndexes = (callback) ->
  tasks = _.values(apps.models).map (model) ->
    (done) -> model.ensureIndexes done
  async.parallel tasks, (e) ->
    return callback e if e
    callback()

helper.resetDatabase = (callback) ->
  mongodbUtil.purgeDatabase (e) ->
    throw e if e
    helper.ensureModelIndexes callback


module.exports = helper
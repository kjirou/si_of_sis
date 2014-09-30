mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
_ = require 'underscore'

mongodbUtil = require 'lib/util/mongodb'


plugins = {}

plugins.baseQueries = (schema, options) ->

  _.extend schema.statics,

    queryOneById: (id) ->
      @findOne({_id:mongodbUtil.toObjectIdCondition id})

    findOneById: (id, callback) ->
      @queryOneById(id).exec callback


getPlugins = ->
  pluginNames = ['baseQueries']
  return (schema, options) ->
    for pluginName in pluginNames
      plugins[pluginName](schema, options)


module.exports =
  getPlugins: getPlugins
  plugins: plugins

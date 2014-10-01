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

plugins.createdAt = (schema, options) ->
  schema.add {
    created_at:
      type: Date
  }
  schema.pre 'save', (callback) ->
    if @isNew
      @created_at = new Date
    callback()

plugins.updatedAt = (schema, options) ->
  schema.add {
    updated_at:
      type: Date
  }
  schema.pre 'save', (callback) ->
    if @isNew and @created_at
      @updated_at = @created_at
    else
      @updated_at = new Date
    callback()


getPlugins = ->
  pluginNames = ['baseQueries', 'createdAt', 'updatedAt']
  return (schema, options) ->
    for pluginName in pluginNames
      plugins[pluginName](schema, options)


module.exports =
  getPlugins: getPlugins
  plugins: plugins

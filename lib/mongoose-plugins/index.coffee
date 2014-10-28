_ = require 'lodash'
mongoose = require 'mongoose'

{assertPopulated, toObjectIdCondition} = require 'modules/mongoose-utils'


@plugins = {}

@plugins.core = (schema, options) ->

  _.extend schema.methods,

    assertPopulated: ->
      (_.partial assertPopulated, @)(arguments...)

  _.extend schema.statics,

    queryOneById: (id) ->
      @findOne({_id: toObjectIdCondition id})

    findOneById: (id, callback) ->
      @queryOneById(id).exec callback

@plugins.createdAt = (schema, options) ->
  schema.add {
    created_at:
      type: Date
  }
  schema.pre 'save', (callback) ->
    if @isNew
      @created_at = new Date
    callback()

@plugins.updatedAt = (schema, options) ->
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

# ゲーム時間へ変換して取得できる virtual を一括定義する
# オプションで渡す fieldNames の各値に 'raw_' を付けたフィール名が対象となる
@plugins.gameDates = (schema, options={}) ->
  {GameDate} = require 'lib/game-date'
  options = _.extend {
    fieldNames: []
  }, options
  options.fieldNames.forEach (fieldName) ->
    schema.virtual(fieldName).get ->
      dateStr = @['raw_' + fieldName]
      if dateStr?
        new GameDate dateStr
      else
        null


# プラグインを一括定義する、オプションは渡せない
@getPlugins = (pluginNames...) ->
  return (schema, options) ->
    for pluginName in pluginNames
      exports.plugins[pluginName](schema, options)

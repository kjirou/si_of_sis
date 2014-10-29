_ = require 'lodash'
mongoose = require 'mongoose'
idExtractor = require 'mongoose-id-extractor-plugin'

{assertPopulated, toObjectIdCondition} = require 'modules/mongoose-utils'


@plugins = {
  idExtractor
}

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

# ゲーム時間データに対するアクセサを一括定義する
@plugins.gameDates = (schema, options={}) ->
  {GameDate} = require 'lib/game-date'
  options = _.extend {
    # 'from_field_path': 'to_field_path' のセット
    map: {}
  }, options
  _.each options.map, (to, from) ->
    schema.virtual(to).get ->
      dateStr = @[from]
      if dateStr?
        new GameDate dateStr
      else
        null


# プラグインを プラグイン名:オプション のセットで一括定義する
@definePlugins = (schema, pluginSettings) ->
  _.forEach pluginSettings, (pluginOptions, pluginName) ->
    exports.plugins[pluginName](schema, pluginOptions ? {})

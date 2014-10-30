_ = require 'lodash'
mongoose = require 'mongoose'
idExtractor = require 'mongoose-id-extractor-plugin'
_s = require 'underscore.string'

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

# 現在HP/最大HPのような現在値と最大値のセットに対し、
# 現在値の消費/補充処理のためのメソッド群を提供する
@plugins.consumable = (schema, options={}) ->
  options = _.extend {
    # 現在値を保持するフィールドパスを指定
    current: undefined
    # 最小値
    min: 0
    # 数値 or 最大値を保持するフィールドパスを指定
    max: undefined
  }, options

  currentFieldPath = options.current
  # e.g. 'foo_bar'     -> 'FooBar'
  #      'foo.bar_baz' -> 'FooBarBaz'
  methodNameBody = _s.classify currentFieldPath.replace /\./, '_'

  getCurrent = (doc) -> doc[currentFieldPath]
  getMin = (doc) -> options.min
  getMax = (doc) -> if _.isString options.max then doc[options.max] else options.max
  getDeltaByRate = (doc, rate, {fraction}={}) ->
    fraction ?= 'ceil'  # 'ceil' or 'floor' or null
    delta = getMax(doc) * rate
    delta = Math[fraction] delta if fraction?
    delta
  updateCurrent = (doc, value) -> doc[currentFieldPath] = value

  # 消費処理群、基本的には最小値を下回る値が指定されたら不正処理
  # 負の数による delta 指定は、発生しないだろうという判断で今はスルー
  consume = (delta) ->
    nextValue = getCurrent(@) - delta
    if nextValue < getMin @
      throw new Error "Cannot consume #{delta} from #{getCurrent @}"
    else
      updateCurrent @, nextValue
  consumeTillMin = (delta) ->
    nextValue = getCurrent(@) - delta
    if nextValue < getMin @
      updateCurrent @, getMin @
    else
      updateCurrent @, nextValue
  canConsume = (delta) ->
    getMin(@) <= getCurrent(@) - delta
  # 供給処理群、基本的には最大値を超える値が指定されても正常処理
  supply = (delta) ->
    nextValue = getCurrent(@) + delta
    if nextValue > getMax @
      updateCurrent @, getMax @
    else
      updateCurrent @, nextValue
  supplyByRate = (rate, options) ->
    supply.apply @, [getDeltaByRate @, rate, options]
  supplyFully = ->
    supplyByRate.apply @, [1.0]

  schema.methods['consume' + methodNameBody] = consume
  schema.methods['consume' + methodNameBody + 'TillMin'] = consumeTillMin
  schema.methods['canConsume' + methodNameBody] = canConsume
  schema.methods['supply' + methodNameBody] = supply
  schema.methods['supply' + methodNameBody + 'ByRate'] = supplyByRate
  schema.methods['supply' + methodNameBody + 'Fully'] = supplyFully


# プラグインを一括定義する
# 1)順番の設定 2)同じプラグインの複数回実行 が要件なので設定は配列である必要がある
@definePlugins = (schema, pluginSettings...) ->
  pluginSettings.forEach (setting) ->
    [pluginName, pluginOptions] = if Array.isArray setting then setting else [setting, undefined]
    exports.plugins[pluginName](schema, pluginOptions ? {})

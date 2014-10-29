_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose

{definePlugins} = require 'lib/mongoose-plugins'
{createValidator} = require 'lib/validator'


#
# プロジェクトイベント
#
schema = new Schema {

  business:
    type: Schema.Types.ObjectId
    ref: 'Business'
    required: true

  # 受注ゲーム週
  raw_ordered_week:
    type: String
    required: true
    validate: [
      createValidator validator: 'isGameDate'
    ]

  # 納品ゲーム週
  raw_delivered_week:
    type: String
    default: null
    validate: [
      createValidator validator: 'isGameDate', passIfNull: true
    ]

  # 進捗、消化済みの必要開発コストということ
  progress:
    type: Number
    default: 0
    required: true
    min: 0

  # 開発終了時の付加価値
  added_value:
    type: Number
    default: 0
    required: true

  # 価格、最終的な支払金額であり記録される値
  price:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]
}

definePlugins schema,
  core: null
  createdAt: null
  updatedAt: null
  gameDates:
    map: raw_ordered_week: 'ordered_week', raw_delivered_week: 'delivered_week'
  idExtractor:
    refs: ['business']


schema.virtual('progress_rate').get ->
  @assertPopulated 'business'
  Math.min @progress / @business.development_cost, 1.0


module.exports = mongoose.model 'Project', schema

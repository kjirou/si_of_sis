mongoose = require 'mongoose'
{Schema} = mongoose

{GameDate} = require 'lib/game-date'
{definePlugins} = require 'lib/mongoose-plugins'
{createValidator} = require 'modules/validator'


#
# 案件リソース
#
schema = new Schema {
  # 案件名
  name:
    type: String
    default: 'Some Project'
    required: true

  # 営業コスト、受注時に消費
  business_cost:
    type: Number
    default: 1
    required: true
    min: 0
    validate: [
      createValidator validator: 'isInt'
    ]

  # 開発コスト、進捗がこの値に到達したら開発完了
  development_cost:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]

  # 提示価格
  asking_price:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]

  # 応募終了週
  raw_closing_week:
    type: Number
    default: GameDate.FIRST_WEEK
    required: true
    min: GameDate.FIRST_WEEK
    max: GameDate.LAST_WEEK
    validate: [
      createValidator validator: 'isInt'
    ]

  # 開発期間
  development_weeks:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]
}

definePlugins schema, 'core', 'createdAt', [
  'gameDates', {
    map:
      raw_closing_week: 'closing_week'
  }
]

# 納期
schema.virtual('delivery_week').get ->
  @closing_week.add @development_weeks


module.exports = mongoose.model 'Business', schema

_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose

{getPlugins} = require 'lib/mongoose-plugins'
{createValidator} = require 'lib/validator'


#
# 案件リソース
#
schema = new Schema {
  # 案件名
  name:
    type: String
    default: 'Some Project'
    required: true

  # 納品物の基本価値
  base_value:
    type: Number
    default: 0
    required: true

  # 開発終了時の付加価値
  added_value:
    type: Number
    default: 0
    required: true

  # 必要開発コスト
  development_cost:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]

  # 進捗、消化済みの必要開発コストということ
  progress:
    type: Number
    default: 0
    required: true
    min: 0

  # 提示価格
  asking_price:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]

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

schema.plugin getPlugins 'core'


schema.virtual('progress_rate').get ->
  Math.min @progress / @development_cost, 1.0


module.exports = mongoose.model 'Business', schema

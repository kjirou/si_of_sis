mongoose = require 'mongoose'
{Schema} = mongoose

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
}

definePlugins schema, 'core', 'createdAt'


module.exports = mongoose.model 'Business', schema

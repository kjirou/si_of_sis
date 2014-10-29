_ = require 'lodash'
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

  # 必要開発コスト
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

definePlugins schema,
  core: null
  createdAt: null


module.exports = mongoose.model 'Business', schema

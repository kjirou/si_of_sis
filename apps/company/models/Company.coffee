_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose

{definePlugins} = require 'lib/mongoose-plugins'
textLib = require 'lib/text'
{createValidator} = require 'modules/validator'


consts =
  MAX_CASH: 9999999999


schema = new Schema {

  user:
    type: Schema.Types.ObjectId
    ref: 'User'
    required: true
    unique: true

  # 会社名、表示用
  name:
    type: String
    default: -> textLib.createRandomCompanyName()
    required: true

  # 現金
  cash:
    type: Number
    default: 0
    required: true
    min: 0
    max: consts.MAX_CASH
    validate: [
      createValidator validator: 'isInt'
    ]

  # 最大営業力
  max_business_power:
    type: Number
    default: 1
    required: true
    min: 1
    validate: [
      createValidator validator: 'isInt'
    ]

  # 現在営業力
  business_power:
    type: Number
    default: 1
    required: true
    min: 0
    validate: [
      createValidator validator: 'isInt'
    ]
}

_.extend schema.statics, consts

definePlugins schema, 'core', 'createdAt', 'updatedAt', [
  'consumable', { current: 'cash', max: consts.MAX_CASH }
], [
  'consumable', { current: 'business_power', max: 'max_business_power' }
]


module.exports = mongoose.model 'Company', schema

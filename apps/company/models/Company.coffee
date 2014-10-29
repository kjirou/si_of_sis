_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose

{definePlugins} = require 'lib/mongoose-plugins'
textLib = require 'lib/text'
{createValidator} = require 'lib/validator'


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
    validate: [
      createValidator validator: 'isPositiveInt'
    ]
}

definePlugins schema,
  core: null
  createdAt: null
  updatedAt: null


module.exports = mongoose.model 'Company', schema

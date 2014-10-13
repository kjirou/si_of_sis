mongoose = require 'mongoose'
{Schema} = mongoose
_ = require 'underscore'

{getPlugins} = require 'lib/mongoose-plugins'
textLib = require 'lib/text'
{createValidator, defaultErrorMessages} = require 'lib/validator'


companySchema = new Schema {

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

companySchema.plugin getPlugins()


module.exports =
  Company: mongoose.model 'Company', companySchema

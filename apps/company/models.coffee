mongoose = require 'mongoose'
{Schema} = mongoose

{getPlugins} = require 'lib/mongoose-plugins'


companySchema = new Schema {

  user:
    type: Schema.Types.ObjectId
    ref: 'User'
    required: true

  # 会社名、表示用
  name:
    type: String
    default: ->
      'Default Company'
    required: true

  # 現金
  cash:
    type: Number
    default: 0
    required: true
}

companySchema.plugin getPlugins()


module.exports =
  Company: mongoose.model 'Company', companySchema

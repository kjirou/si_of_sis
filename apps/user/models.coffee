mongoose = require 'mongoose'
{Schema} = mongoose


UserSchema = new Schema {
  email:
    type: String
    index:
      unique: true
      sparse: true
}


module.exports =
  User: mongoose.model 'User', UserSchema

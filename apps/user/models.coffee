mongoose = require 'mongoose'
{Schema} = mongoose


UserSchema = new Schema {
  email:
    type: String
    required: true
    index:
      unique: true
      sparse: true

  # ハッシュ化されたパスワード
  password:
    type: String
    required: true

  salt:
    type: String
    required: true
    unique: true
}


module.exports =
  User: mongoose.model 'User', UserSchema

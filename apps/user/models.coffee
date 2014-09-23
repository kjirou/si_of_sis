mongoose = require 'mongoose'
{Schema} = mongoose

cryptoUtil = require 'lib/util/crypto'


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

UserSchema.methods.verifyPassword = (rawPassword) ->
  @password is cryptoUtil.generateHashedPassword rawPassword, @salt


module.exports =
  User: mongoose.model 'User', UserSchema

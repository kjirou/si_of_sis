mongoose = require 'mongoose'
{Schema} = mongoose

cryptoUtil = require 'lib/util/crypto'


UserSchema = new Schema {
  email:
    type: String
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
}


UserSchema.statics.queryActiveUsers = -> @where()

UserSchema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).limit 1


UserSchema.methods.verifyPassword = (rawPassword) ->
  @password is cryptoUtil.generateHashedPassword rawPassword, @salt


module.exports =
  User: mongoose.model 'User', UserSchema

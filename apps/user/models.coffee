mongoose = require 'mongoose'
{Schema} = mongoose
randomString = require 'random-string'
_ = require 'underscore'

{generateHashedPassword} = require 'lib/util/crypto'


consts =
  SALT_LENGTH: 20


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

  # 必ず存在する、required 無い点は #46 参照
  salt:
    type: String
    default: ->
      randomString length:consts.SALT_LENGTH
}


_.extend UserSchema.statics, consts


UserSchema.statics.queryActiveUsers = -> @where()

UserSchema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).limit 1


UserSchema.methods.setPassword = (rawPassword) ->
  @password = generateHashedPassword rawPassword, @salt

UserSchema.methods.verifyPassword = (rawPassword) ->
  @password is generateHashedPassword rawPassword, @salt


module.exports =
  User: mongoose.model 'User', UserSchema

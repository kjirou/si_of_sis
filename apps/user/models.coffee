mongoose = require 'mongoose'
{Schema} = mongoose
randomString = require 'random-string'
_ = require 'underscore'

{getPlugins} = require 'lib/mongoose-plugins'
{generateHashedPassword} = require 'lib/crypto'


consts =
  SALT_LENGTH: 20


userSchema = new Schema {
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

userSchema.plugin getPlugins()

_.extend userSchema.statics, consts


userSchema.statics.queryActiveUsers = -> @where()

userSchema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).findOne()


userSchema.methods.setPassword = (rawPassword) ->
  @password = generateHashedPassword rawPassword, @salt

userSchema.methods.verifyPassword = (rawPassword) ->
  @password is generateHashedPassword rawPassword, @salt


module.exports =
  User: mongoose.model 'User', userSchema

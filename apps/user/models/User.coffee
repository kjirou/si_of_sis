_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose
randomString = require 'random-string'

{getPlugins} = require 'lib/mongoose-plugins'
{generateHashedPassword} = require 'lib/crypto'


consts =
  SALT_LENGTH: 20


schema = new Schema {
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

schema.plugin getPlugins 'core', 'createdAt', 'updatedAt'

_.extend schema.statics, consts


schema.statics.queryActiveUsers = -> @where()

schema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).findOne()


schema.methods.setPassword = (rawPassword) ->
  @password = generateHashedPassword rawPassword, @salt

schema.methods.verifyPassword = (rawPassword) ->
  @password is generateHashedPassword rawPassword, @salt


module.exports = mongoose.model 'User', schema

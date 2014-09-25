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

  # 必ず存在する、required 無い点は #46 参照
  salt:
    type: String
}


UserSchema.statics.queryActiveUsers = -> @where()

UserSchema.statics.queryActiveUserByEmail = (email) ->
  @queryActiveUsers().where({email: email}).limit 1


UserSchema.methods.verifyPassword = (rawPassword) ->
  @password is cryptoUtil.generateHashedPassword rawPassword, @salt

UserSchema.methods._generateSalt = -> @_id.toString() + '_salt'


UserSchema.pre 'save', (callback) ->
  if @isNew
    @salt = @_generateSalt()
  callback()


module.exports =
  User: mongoose.model 'User', UserSchema

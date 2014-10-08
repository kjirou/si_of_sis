LocalStrategy = require('passport-local').Strategy

{User} = require 'apps/user/models'
{Field, Form} = require 'lib/validator'


logics = {}

logics.passportConfigurations =

  # passport.use へ渡す、新しくログインする際のログイン判定処理
  # passport.authenticate で生成したミドルウェアを実行した時に起動する
  localStrategy: ->
    new LocalStrategy {
      usernameField: 'email'
    }, (email, password, next) ->
      User.queryActiveUserByEmail(email).findOne (e, user) ->
        if e
          next e
        else if user?.verifyPassword password
          next null, user
        else
          next null, null

  # passport.serializeUser へ渡す、
  # ログイン成功後に、セッションDBへその状態を格納する処理
  serializeUser: ->
    (user, callback) ->
      callback null, user._id.toString()

  # passport.deserializeUser へ渡す、
  # ログイン済みの場合に、セッションDBからログイン状態を復元する処理
  deserializeUser: ->
    (userId, callback) ->
      User.findOneById userId, (e, user) ->
        return callback e if e
        callback null, user ? null

class UserForm extends Form
  constructor: ->
    super
    self = @
    @_user = null
    @field 'email', ((new Field)
      .type 'isRequired'
      .type 'isEmail'
      .type 'isLength', [1, 64]
      .custom ({value}, callback) ->
        User.queryActiveUserByEmail(value).findOne().exec (e, user) ->
          if e
            callback e
          else if not user or self._user?.email is value
            callback null, {isValid:true}
          else
            callback null, {isValid:false, message:'Duplicated email'}
    )
    @field 'password', ((new Field)
      .type 'isRequired'
      .type 'isAlphanumeric'
      .type 'isLength', [4, 16]
    )
  bindUser: (@_user) ->

logics.postUser = (user, values, callback) ->
  form = new UserForm values
  if user
    form.bindUser user
    form.getField('password').options.passIfEmpty = true
  else
    user = new User
  form.validate (e, validated) ->
    return callback e if e
    return callback null, validated unless validated.isValid
    user.email = values.email
    user.setPassword values.password if values.password
    user.save callback


module.exports = logics

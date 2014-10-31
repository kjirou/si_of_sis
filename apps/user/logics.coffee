_ = require 'lodash'
LocalStrategy = require('passport-local').Strategy

{Company} = require 'apps/company/models'
{User} = require 'apps/user/models'
{Http500Error} = require 'lib/errors'
{Field, Form} = require 'modules/validator'


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

  # ログイン成功後に、セッションDBへその状態を格納する処理
  # passport.serializeUser へ設定する
  serializeUser: ->
    (user, callback) ->
      callback null, user._id.toString()

  # ログイン済みの場合に、セッションDBからログイン状態を復元する処理
  # passport.deserializeUser へ設定する
  deserializeUser: ->
    (userIdFromSession, callback) ->
      User.findOneById userIdFromSession, (e, user) ->
        return if e
          callback e
        # セッション上はログイン済みだが、User情報が削除されていた場合に
        # ログイン状態を解除する
        # Ref) https://github.com/jaredhanson/passport/issues/6#issuecomment-4857287
        else unless user
          callback null, false
        Company.findOne {user:user._id}, (e, company) ->
          return if e
            callback e
          else unless company
            callback new Http500Error 'Cannot find user\'s company'
          # e.g.
          #
          #   req.user = {
          #     user: User ドキュメント
          #     company: Company ドキュメント
          #   }
          #
          # req.user へ直接ドキュメントを格納していない。
          # 理由は、この場合 req.user.company などに特異プロパティで他ドキュメントを
          # 設定する必要があるが、mongoose 側でそれが期待された使い方では無さそうだから。
          callback null,
            user: user
            company: company

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
  isNew = true
  if user
    isNew = false
    form.bindUser user
    form.getField('password').options.passIfEmpty = true
  else
    user = new User
  form.validate (e, validated) ->
    return callback e if e
    return callback null, validated unless validated.isValid
    user.email = values.email
    user.setPassword values.password if values.password
    user.save (e) ->
      return callback e if e
      if isNew
        company = new Company
        company.user = user._id
        company.cash = 10000 + _.random 40000
        company.max_stamina = 100 + _.random 100
        company.supplyStaminaFully()
        company.save (e) ->
          return callback e if e
          callback null, user
      else
        callback null, user


module.exports = logics

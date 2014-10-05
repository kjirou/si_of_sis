{User} = require 'apps/user/models'
{Field, Form} = require 'lib/validator'


logics = {}

logics.UserForm = class UserForm extends Form
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

logics.updateUser = (user, values, callback) ->
  form = new UserForm values
  if user
    form.bindUser user
  else
    user = new User
  form.validate (e, validated) ->
    return callback e if e
    return callback null, validated unless validated.isValid
    user.email = values.email
    user.setPassword values.password
    user.save callback


module.exports = logics

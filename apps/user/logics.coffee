{User} = require 'apps/user/models'
{Field, Form} = require 'lib/validator'


logics = {}

logics.UserForm = class UserForm extends Form
  constructor: ->
    super
    @field 'email', ((new Field)
      .type 'isRequired'
      .type 'isEmail'
      .type 'isLength', [1, 64]
    )
    @field 'password', ((new Field)
      .type 'isRequired'
      .type 'isAlphanumeric'
      .type 'isLength', [4, 16]
    )

logics.updateUser = (user, values, callback) ->
  isUpdate = Boolean user
  user = user ? new User
  form = new UserForm values
  form.validate (e, validated) ->
    return callback e if e
    return callback null, validated unless validated.isValid
    user.email = values.email
    user.setPassword values.password
    user.save callback


module.exports = logics

async = require 'async'
{ObjectId} = require('mongoose').Types
_ = require 'underscore'
validator = require 'validator'

{User} = require './models'


renderUpdatePage = (res, data={}) ->
  res.renderSubApp 'update', _.extend {
    inputs: {}
    errors: {}
  }, data

updateAction = (id, req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  async.waterfall [
    (nextStep) ->
      if id?
        User.findOne({_id:ObjectId(id)}).findOne (e, user) ->
          if e
            nextStep e
          else unless user
            nextStep new Error '404'
          else
            nextStep null, user
      else
        nextStep null, new User
  ], (e, user) ->
    return next e if e

    errors = {}
    unless validator.isEmail inputs.email
      errors.email = { message:'Invalid email.' }
    unless validator.isLength inputs.password, 4, 16
      errors.password = { message:'Invalid password.' }

    if _.size(errors) > 0
      return renderUpdatePage res, {
        inputs: inputs
        errors: errors
      }

    user.email = inputs.email
    user.setPassword inputs.password
    user.save (e) ->
      return next e if e
      res.redirect '/home'


controllers = {}

controllers.create = (req, res, next) ->
  switch req.method
    when 'GET'
      renderUpdatePage res
    when 'POST'
      updateAction null, arguments...
    else
      next new Error 404

controllers['update/:id'] = (req, res, next) ->
  switch req.method
    when 'GET'
      User.findOne({_id:ObjectId(req.params.id)}).findOne (e, user) ->
        if e
          next e
        else unless user
          next new Error '404'
        else
          renderUpdatePage res, {
            inputs:
              email: user.email
          }
    when 'POST'
      updateAction req.params.id, arguments...
    else
      next new Error 404


module.exports = controllers

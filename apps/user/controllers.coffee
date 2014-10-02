async = require 'async'
{chain} = require 'express-nested-router'
{ObjectId} = require('mongoose').Types
_ = require 'underscore'
validator = require 'validator'

{User} = require './models'
{Http404Error} = require 'lib/errors'
{requireObjectId} = require 'lib/middlewares'


renderUpdatePage = (res, data={}) ->
  res.renderSubApp 'update', _.extend {
    inputs: {}
    errors: {}
  }, data

updateAction = (user, req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  user = user ? new User

  errors = {}
  unless validator.isEmail inputs.email
    errors.email = { message:'Invalid email.' }
  unless validator.isLength inputs.password, 4, 16
    errors.password = { message:'Invalid password.' }

  if _.size(errors) > 0
    return renderUpdatePage res,
      inputs: inputs
      errors: errors

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
      next new Http404Error

controllers['update/:id'] = chain requireObjectId(User), (req, res, next) ->
  switch req.method
    when 'GET'
      renderUpdatePage res,
        inputs:
          email: req.doc.email
    when 'POST'
      updateAction req.doc, arguments...
    else
      next new Http404Error


module.exports = controllers

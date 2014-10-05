async = require 'async'
{chain} = require 'express-nested-router'
{ObjectId} = require('mongoose').Types
_ = require 'underscore'
validator = require 'validator'

logics = require './logics'
{User} = require './models'
{Http404Error} = require 'lib/errors'
{requireObjectId} = require 'lib/middlewares'


renderUpdatePage = (res, data={}) ->
  res.renderSubApp 'update', _.extend {
    inputs: {}
    errors: {}
  }, data

updateAction = (userOrNull, req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  logics.updateUser userOrNull, inputs, (e, result) ->
    if e
      next e
    else if result instanceof User
      res.redirect '/home'
    else
      renderUpdatePage res, {
        inputs: inputs
        errors: result.errors
      }


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

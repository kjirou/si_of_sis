async = require 'async'
{chain} = require 'express-nested-router'
{ObjectId} = require('mongoose').Types
_ = require 'underscore'
validator = require 'validator'

logics = require './logics'
{User} = require './models'
{Http404Error} = require 'lib/errors'
{requireObjectId} = require 'lib/middlewares'


renderPostPage = (res, data={}) ->
  res.renderSubApp 'post', _.extend {
    inputs: {}
    errors: {}
  }, data

postAction = (userOrNull, req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  logics.postUser userOrNull, inputs, (e, result) ->
    if e
      next e
    else if result instanceof User
      res.redirect '/home'
    else
      renderPostPage res, {
        inputs: inputs
        errors: result.errors
      }


controllers = {}

controllers.create = (req, res, next) ->
  switch req.method
    when 'GET'
      renderPostPage res
    when 'POST'
      postAction null, arguments...
    else
      next new Http404Error

controllers['update/:id'] = chain requireObjectId(User), (req, res, next) ->
  switch req.method
    when 'GET'
      renderPostPage res,
        inputs:
          email: req.doc.email
    when 'POST'
      postAction req.doc, arguments...
    else
      next new Http404Error


module.exports = controllers

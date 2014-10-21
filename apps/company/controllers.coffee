{chain} = require 'express-nested-router'
_ = require 'underscore'

logics = require './logics'
{Company} = require './models'
{Http404Error} = require 'lib/errors'
{requireObjectId} = require 'lib/middlewares/core'


controllers = {}

controllers['update/:id'] = chain requireObjectId(Company), (req, res, next) ->
  inputs = _.extend {
    name: ''
  }, req.body

  switch req.method
    when 'GET'
      res.subApp.renderPostPage
        inputs: req.doc.toObject()
    when 'POST'
      logics.postCompany req.doc, inputs, (e, result) ->
        if e
          next e
        else if result instanceof Company
          req.xflash 'success', 'Update was completed.'
          res.redirect req.path
        else
          res.subApp.renderPostPage
            inputs: inputs
            errors: result.errors
    else
      next new Http404Error


module.exports = controllers

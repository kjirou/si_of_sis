chain = require 'connect-chain'
_ = require 'lodash'

logics = require './logics'
{Business} = require 'apps/business/models'
{Http404Error} = require 'lib/errors'
{requireObjectId} = require 'lib/middlewares/core'


controllers = {}

controllers['create/:id'] = chain requireObjectId(Business), (req, res, next) ->
  inputs = _.extend {
    name: ''
  }, req.body

  switch req.method
    when 'GET'
      res.subApp.renderForm 'post',
        inputs: req.doc.toObject()
    when 'POST'
      logics.postCompany req.doc, inputs, (e, any) ->
        if e
          next e
        else if any instanceof Company
          req.xflash 'success', 'Update was completed.'
          res.redirect req.path
        else
          res.subApp.renderForm 'post',
            inputs: inputs
            error: any.reporter
    else
      next new Http404Error


module.exports = controllers

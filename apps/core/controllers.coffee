passport = require 'passport'
_ = require 'underscore'

{Http404Error} = require 'lib/errors'
{ErrorReporter, Form} = require 'modules/validator'


controllers = {}

controllers.index = (req, res, next) ->
  res.subApp.render 'index'

controllers.login = (req, res, next) ->
  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  switch req.method
    when 'GET'
      res.subApp.renderForm 'login'
    when 'POST'
      authMiddleware = passport.authenticate 'local', (e, user) ->
        if e
          next e
        else unless user
          reporter = new ErrorReporter
          reporter.error 'email', 'Invalid email or password'
          res.subApp.renderForm 'login', {
            inputs: inputs
            error: reporter
          }
        else
          req.login user, (e) ->
            return next e if e
            res.redirect '/home'
      authMiddleware req, res, next
    else
      next new Http404Error

controllers.logout = (req, res, next) ->
  req.logout()
  res.redirect '/'

module.exports = controllers

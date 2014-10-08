passport = require 'passport'
_ = require 'underscore'

{Http404Error} = require 'lib/errors'
{ErrorReporter, Form} = require 'lib/validator'


controllers = {}

controllers.index = (req, res, next) ->
  res.renderSubApp 'index'

controllers.login = (req, res, next) ->
  renderLoginPage = (locals={}) ->
    res.renderSubApp 'login', _.extend {
      inputs: {}
      errors: {}
    }, locals

  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  switch req.method
    when 'GET'
      renderLoginPage()
    when 'POST'
      authMiddleware = passport.authenticate 'local', (e, user) ->
        if e
          next e
        else unless user
          reporter = new ErrorReporter
          reporter.error 'email', 'Invalid email or password'
          renderLoginPage {
            inputs: inputs
            errors: reporter.report()
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

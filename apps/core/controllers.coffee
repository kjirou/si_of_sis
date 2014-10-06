passport = require 'passport'
_ = require 'underscore'

{Http404Error} = require 'lib/errors'
{ErrorReporter, Form} = require 'lib/validator'


controllers = {}

controllers.index = (req, res, next) ->
  res.renderSubApp 'index'

controllers.login = (req, res, next) ->
  renderPage = (data={}) ->
    res.renderSubApp 'login', _.extend {
      inputs: {}
      errors: {}
    }, data

  inputs = _.extend {
    email: ''
    password: ''
  }, req.body

  switch req.method
    when 'GET'
      renderPage()
    when 'POST'
      (passport.authenticate 'local', (e, user) ->
        if e
          next e
        else unless user
          reporter = new ErrorReporter
          reporter.set 'email', 'Invalid email or password'
          renderPage {
            inputs: inputs
            errors: reporter.report()
          }
        else
          req.login user, (e) ->
            return next e if e
            res.redirect '/home'
      )(req, res, next)
    else
      next new Http404Error

controllers.logout = (req, res, next) ->
  req.logout()
  res.redirect '/'

module.exports = controllers

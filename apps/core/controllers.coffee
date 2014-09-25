passport = require 'passport'


controllers = {}

controllers.index = (req, res, next) ->
  res.renderSubApp 'index'

controllers.login = (req, res, next) ->
  switch req.method
    when 'POST'
      (passport.authenticate 'local', (e, user) ->
        if e
          next e
        else unless user
          res.redirect '/login?failue=1'
        else
          req.logIn user, (e) ->
            return next e if e
            res.redirect '/?logged_in=1'
      )(req, res, next)
    else
      res.renderSubApp 'login'

controllers.logout = (req, res, next) ->
  req.logout()
  res.redirect '/'

module.exports = controllers

_ = require 'underscore'


middlewares =

  requireUser: (options={}) ->
    options = _.extend {
      redirectTo: null
    }, options

    (req, res, next) ->
      unless req.user
        if options.redirectTo?
          res.redirect options.redirectTo
        else
          next new Error '404 by requireUser'  # @TODO
      else
        next()

  requireLogin: ->
    middlewares.requireUser {
      redirectTo: '/login'
    }


module.exports = middlewares

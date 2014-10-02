_ = require 'underscore'

{Http404Error} = require 'lib/errors'


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
          next new Http404Error
      else
        next()

  requireLogin: ->
    middlewares.requireUser {
      redirectTo: '/login'
    }


module.exports = middlewares

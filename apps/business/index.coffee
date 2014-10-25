router = require 'express-nested-router'

controllers = require './controllers'
authenticationMiddleware = require 'lib/middlewares/authentication'


routes = router.namespace controllers
routes.pushBeforeMiddleware authenticationMiddleware.requireLogin()


module.exports = routes

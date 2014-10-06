router = require 'express-nested-router'

controllers = require './controllers'


module.exports = router.namespace controllers

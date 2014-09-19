router = require 'express-nested-router'

coreRoutes = require './core/routes'


namespace = module.exports = router.namespace coreRoutes

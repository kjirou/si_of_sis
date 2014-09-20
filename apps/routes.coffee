router = require 'express-nested-router'

coreRoutes = require './core/routes'


namespace = router.namespace coreRoutes

module.exports = namespace

var router = require('express-nested-router');

var coreRoutes = require('./core/routes');


var namespace = module.exports = router.namespace(coreRoutes);

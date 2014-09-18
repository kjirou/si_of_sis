var router = require('express-nested-router');

var controllers = require('./controllers');


module.exports = router.namespace(controllers);

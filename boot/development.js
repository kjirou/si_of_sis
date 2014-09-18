process.env.NODE_PATH = __dirname + '/..';
require('module')._initPaths();
process.env.NODE_ENV = 'development';

var app = require('apps/app');
app.listen(3000);

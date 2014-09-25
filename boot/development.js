#!/usr/bin/env node

require('coffee-script/register');

require('../env/development');

var http = require('http');

var conf = require('conf');


var app = require('apps/app');
http.createServer(app).listen(conf.server.port, function(){
  console.log('Express server listening on port ' + conf.server.port);
});

var express = require('express');
var router = require('express-nested-router');

var config = require('config');
var routes = require('apps/routes');


var app = module.exports = express();

routes.resolve(app);

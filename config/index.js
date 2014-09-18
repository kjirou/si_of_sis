var path = require('path');
var express = require('express');


var config = module.exports = {
  debug: true,
  env: express().get('env'),
  root: path.resolve(process.env.NODE_PATH)
};

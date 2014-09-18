var express = require('express');


var config = module.exports = {
  env: express().get('env'),
  debug: true
};

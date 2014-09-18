var express = require('express');


var config = {
  env: express().get('env'),
  debug: true
};

// 環境別コンフィグの読み込み

module.exports = config;

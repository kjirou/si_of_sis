#!/usr/bin/env node

require('coffee-script/register');

require('../env/fixture');

var program = require('commander');

var fixtures = require('fixtures');


program
  .version('0.0.1')
  .option('-d --development', '開発環境用の初期データを入れる')
  .parse(process.argv)
;

var params = {
  isForDevelopment: !!program.development
};

fixtures.execute(params);

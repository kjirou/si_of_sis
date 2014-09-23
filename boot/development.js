#!/usr/bin/env node

require('coffee-script/register');

require('../env/development');


var app = require('apps/app');
app.listen(3000);

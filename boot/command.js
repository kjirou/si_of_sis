#!/usr/bin/env node

require('coffee-script/register');

require('../env/cli');

var commands = require('commands');


commands.execute()

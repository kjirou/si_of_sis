process.env.NODE_ENV = 'development'
process.env.NODE_PATH = __dirname + '/..'
require('module')._initPaths()


config = require 'config'


config.mongodb.prepareConnections()

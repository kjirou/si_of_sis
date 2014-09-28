process.env.NODE_ENV = 'cli'
process.env.NODE_PATH = __dirname + '/..'
require('module')._initPaths()


conf = require 'conf'


conf.mongodb.prepareConnections()

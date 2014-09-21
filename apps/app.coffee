express = require 'express'
router = require 'express-nested-router'

config = require 'config'
routes = require 'apps/routes'


app = express()

# Routing
routes.resolve app

# Templating
app.set 'views', "#{config.root}/views"
app.set 'view engine', 'jade'

module.exports = app

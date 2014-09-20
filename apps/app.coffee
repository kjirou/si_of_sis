express = require 'express'
router = require 'express-nested-router'

config = require 'config'
routes = require 'apps/routes'


app = express()

routes.resolve app

module.exports = app

express = require 'express'
router = require 'express-nested-router'

config = require 'config'
routes = require 'apps/routes'


app = module.exports = express()

routes.resolve app

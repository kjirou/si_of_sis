express = require 'express'
router = require 'express-nested-router'

config = require 'config'
routes = require 'apps/routes'
{createSubAppMiddleware} = require 'lib/middlewares'


app = express()

#
# Settings
#
app.set 'views', "#{config.root}/views"
app.set 'view engine', 'jade'


#
# Set middlewares
#

# サブアプリ情報を設定する
for subAppName, subAppNamespace of routes.subAppNamespaces
  subAppNamespace.unshiftBeforeMiddleware(createSubAppMiddleware subAppName)


#
# Resolve routes
#
routes.namespace.resolve app


module.exports = app

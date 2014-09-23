express = require 'express'
path = require 'path'
router = require 'express-nested-router'

conf = require 'conf'
routes = require 'apps/routes'
{createSubAppMiddleware} = require 'lib/middlewares'


app = express()

#
# Settings
#
app.set 'views', path.join(conf.root, '/views')
app.set 'view engine', 'jade'


#
# Locals
#
app.locals =
  basedir: app.get 'views'


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

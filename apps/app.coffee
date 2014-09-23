express = require 'express'
MongoStore = require('connect-mongo')(express)
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
app.use express.cookieParser()
app.use express.json()
app.use express.urlencoded()
#app.use express.multipart()  # Ref) #37
app.use express.session {
  secret: conf.session.secret
  cookie: {
    maxAge: 365 * 24 * 60 * 60 * 1000
  }
  store: new MongoStore {
    db: conf.session.mongodb.databaseName
    host: conf.session.mongodb.host
    port: conf.session.mongodb.port
    username: conf.session.mongodb.user
    password: conf.session.mongodb.pass
    clear_interval: 3600
  }
}

for subAppName, subAppNamespace of routes.subAppNamespaces
  subAppNamespace.pushBeforeMiddleware(createSubAppMiddleware subAppName)


#
# Resolve routes
#
routes.namespace.resolve app


module.exports = app

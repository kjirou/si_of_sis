express = require 'express'
router = require 'express-nested-router'
_ = require 'lodash'
_s = require 'underscore.string'
passport = require 'passport'
pathModule = require 'path'
LocalStrategy = require('passport-local').Strategy

apps = require 'apps'
{passportConfigurations} = require 'apps/user/logics'
{User} = require 'apps/user/models'
conf = require 'conf'
{applySubAppData, csrf, disableCsrf, jsonApi, logServer} = require 'lib/middlewares/core'
xflashMiddleware = require 'lib/middlewares/extended-connect-flash'


app = express()

#
# Settings
#
app.set 'views', pathModule.join(conf.root, '/views')
app.set 'view engine', 'jade'
#app.set 'view options', {}


#
# Locals
#
app.locals =
  _: _
  _s: _s
  basedir: app.get 'views'
  pretty: true


#
# Passport Configurations
#
passport.use passportConfigurations.localStrategy()
passport.serializeUser passportConfigurations.serializeUser()
passport.deserializeUser passportConfigurations.deserializeUser()


#
# Middlewares
#
app.use logServer()
app.use express.cookieParser()
app.use express.json()
app.use express.urlencoded()
#app.use express.multipart()  # Ref) #37
app.use xflashMiddleware()
app.use express.session {
  secret: conf.session.secret
  cookie: {
    maxAge: 365 * 24 * 60 * 60 * 1000
  }
  store: conf.session.mongodbStore.prepareConnection()
}
if conf.env is 'test'
  app.use disableCsrf()
app.use csrf()
app.use passport.initialize()
app.use passport.session()
app.use (req, res, next) ->
  _.extend res.locals,
    req: req
  next()
app.use jsonApi()
app.use app.router
app.use(express.static(pathModule.join(conf.root, 'public')))

for subAppName, subApp of apps.subApps when subApp.routes
  subApp.routes.pushBeforeMiddleware(applySubAppData subAppName)


#
# Resolve Routes
#
apps.routes.resolve app


module.exports = app

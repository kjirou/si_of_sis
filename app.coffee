express = require 'express'
router = require 'express-nested-router'
passport = require 'passport'
pathModule = require 'path'
LocalStrategy = require('passport-local').Strategy

apps = require 'apps'
{passportConfigurations} = require 'apps/user/logics'
{User} = require 'apps/user/models'
conf = require 'conf'
{applySubAppData, csrf, disableCsrf} = require 'lib/middlewares/core'
xflashMiddleware = require 'lib/middlewares/extended-connect-flash'


app = express()

#
# Settings
#
app.set 'views', pathModule.join(conf.root, '/views')
app.set 'view engine', 'jade'


#
# Locals
#
app.locals =
  basedir: app.get 'views'


#
# Passport Configurations
#
passport.use passportConfigurations.localStrategy()
passport.serializeUser passportConfigurations.serializeUser()
passport.deserializeUser passportConfigurations.deserializeUser()


#
# Middlewares
#
switch conf.env
  when 'development'
    app.use express.logger { format:'dev' }
  when 'production'
    app.use express.logger { format:'combined' }
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
  res.locals.req = req
  next()
app.use app.router
app.use(express.static(pathModule.join(conf.root, 'public')))

for subAppName, subApp of apps.subApps when subApp.routes
  subApp.routes.pushBeforeMiddleware(applySubAppData subAppName)


#
# Resolve Routes
#
apps.routes.resolve app


module.exports = app

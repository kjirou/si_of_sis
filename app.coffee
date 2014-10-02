express = require 'express'
MongoStore = require('connect-mongo')(express)
router = require 'express-nested-router'
passport = require 'passport'
pathModule = require 'path'
LocalStrategy = require('passport-local').Strategy

apps = require 'apps'
{User} = require 'apps/user/models'
conf = require 'conf'
{createSubAppMiddleware} = require 'lib/middlewares'


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
passport.use(
  new LocalStrategy {
    usernameField: 'email'
  }, (email, password, next) ->
    User.queryActiveUserByEmail(email).findOne (e, user) ->
      if e
        next e
      else if user?.verifyPassword password
        next null, user
      else
        next null, null
)

passport.serializeUser (user, callback) ->
  callback null, user._id.toString()

passport.deserializeUser (userId, callback) ->
  User.findOne userId, (e, user) ->
    return callback e if e
    callback null, user ? null


#
# Middlewares Settings
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
app.use passport.initialize()
app.use passport.session()
app.use (req, res, next) ->
  res.locals.req = req
  next()
app.use app.router
app.use(express.static(pathModule.join(conf.root, 'public')))

for subAppName, subApp of apps.subApps when subApp.routes
  subApp.routes.pushBeforeMiddleware(createSubAppMiddleware subAppName)


#
# Resolve Routes
#
apps.routes.resolve app


module.exports = app

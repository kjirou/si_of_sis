async = require 'async'
_ = require 'underscore'
wantit = require 'wantit'


#
# Sub Applications
#
subAppNames = [
  'company'
  'core'
  'home'
  'user'
]

subApps = {}
for subAppName in subAppNames
  path = "apps/#{subAppName}"
  subApps[subAppName] =
    path: path
    models: wantit "#{path}/models"
    logics: wantit "#{path}/logics"
    routes: wantit "#{path}"


#
# Models
#
models = {}
for unused, subApp of subApps
  _.extend models, subApp.models ? {}


#
# Routing
#
do ({company, core, home, user}=subApps) ->
  core.routes.addRoute 'company', company.routes
  core.routes.addRoute 'home', home.routes
  core.routes.addRoute 'user', user.routes


module.exports =
  routes: subApps.core.routes
  models: models
  subApps: subApps

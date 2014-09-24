wantit = require 'wantit'


#
# Sub Applications
#
subAppNames = [
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
    routes: wantit "#{path}/routes"

{core, home, user} = subApps


#
# Routing
#
core.routes.addRoute 'home', home.routes


module.exports =
  routes: subApps.core.routes
  subApps: subApps

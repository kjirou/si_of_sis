async = require 'async'
_ = require 'underscore'
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


#
# Models
#
models = {}
for unused, subApp of subApps
  _.extend models, subApp.models ? {}


#
# Routing
#
{core, home, user} = subApps
core.routes.addRoute 'home', home.routes


module.exports =
  routes: subApps.core.routes
  models: models
  subApps: subApps

  # 全 Model のインデックスを再生成する
  ensureModelIndexes: (callback) ->
    tasks = _.values(models).map (model) ->
      (done) -> model.ensureIndexes done
    async.parallel tasks, (e) ->
      throw e if e
      callback()

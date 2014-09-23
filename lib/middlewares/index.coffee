_ = require 'underscore'

conf = require 'conf'
coreLib = require 'lib/core'


module.exports =

  # サブアプリ情報を設定するミドルウェアを作成する
  createSubAppMiddleware: (subAppName) ->
    (req, res, next) ->
      subAppViewRoot = "#{conf.root}/views/apps/#{subAppName}"

      req.subApp =
        name: subAppName
        root: "#{root}/apps/#{subAppName}"
        viewRoot: subAppViewRoot

      res.renderSubApp = coreLib.bindPathRoot subAppViewRoot, res.render

      next()

_ = require 'underscore'

config = require 'config'


module.exports =

  # サブアプリ情報を設定するミドルウェアを作成する
  createSubAppMiddleware: (subAppName) ->
    (req, res, next) ->
      subAppViewRoot = "#{config.root}/views/apps/#{subAppName}"

      req.subApp =
        name: subAppName
        root: "#{root}/apps/#{subAppName}"
        viewRoot: subAppViewRoot

      res.renderSubApp = ->
        args = _.toArray arguments
        if args[0]?
          args[0] = "#{subAppViewRoot}/#{args[0]}"
        res.render.apply res, args

      next()

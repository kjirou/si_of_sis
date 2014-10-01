_ = require 'underscore'

conf = require 'conf'
coreLib = require 'lib/core'
mongodbUtil = require 'lib/util/mongodb'


module.exports =

  # サブアプリ情報を設定するミドルウェアを生成する
  createSubAppMiddleware: (subAppName) ->
    (req, res, next) ->
      subAppViewRoot = "#{conf.root}/views/apps/#{subAppName}"

      req.subApp =
        name: subAppName
        root: "#{root}/apps/#{subAppName}"
        viewRoot: subAppViewRoot

      res.renderSubApp = coreLib.bindPathRoot subAppViewRoot, res.render

      next()

  # パスの :id に対応するドキュメントを抽出し req.doc へ格納するミドルウェアを生成する
  createDocIdMiddleware: (model) ->
    (req, res, next) ->
      id = mongodbUtil.toObjectIdCondition req.params.id
      unless id
        req.doc = null
        return next null, null
      model.findOne {_id:id}, (e, doc) ->
        return next e if e
        req.doc = doc ? null
        next()

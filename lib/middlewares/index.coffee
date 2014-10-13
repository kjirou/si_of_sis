_ = require 'underscore'

conf = require 'conf'
coreLib = require 'lib/core'
{Http404Error} = require 'lib/errors'
mongooseUtils = require 'modules/mongoose-utils'


middlewares =

  # サブアプリ情報を設定する
  applySubAppData: (subAppName) ->
    (req, res, next) ->
      subAppViewRoot = "#{conf.root}/views/apps/#{subAppName}"

      req.subApp =
        name: subAppName
        root: "#{root}/apps/#{subAppName}"
        viewRoot: subAppViewRoot

      res.subApp = {}

      res.renderSubApp = coreLib.bindPathRoot subAppViewRoot, res.render

      res.subApp.renderPostPage = (locals={}) ->
        res.renderSubApp 'post', _.extend {
          inputs: {}
          errors: {}
        }, locals

      next()

  # パス内の :id から指定モデルのドキュメントを抽出し req.doc へ格納する
  # パス以外からも受け取れるようにする必要が出るかも
  applyObjectId: (model, options={}) ->
    options = _.extend {
      # doc が抽出できなかった場合にエラーを返すか
      errorClass: null
    }, options

    (req, res, next) ->
      toNext = ->
        if not req.doc and options.errorClass
          next new options.errorClass
        else
          next()
      req.doc = null

      id = mongooseUtils.toObjectIdCondition req.params.id
      return toNext() unless id

      model.findOne {_id:id}, (e, doc) ->
        if e
          next e
        else
          req.doc = doc if doc
          toNext()

  requireObjectId: (model) ->
    middlewares.applyObjectId model, errorClass:Http404Error


module.exports = middlewares

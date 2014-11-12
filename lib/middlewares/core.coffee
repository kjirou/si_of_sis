express = require 'express'
_ = require 'lodash'
morgan = require 'morgan'
urlModule = require 'url'

conf = require 'conf'
coreLib = require 'lib/core'
{Http404Error} = require 'lib/errors'
mongooseUtils = require 'modules/mongoose-utils'


# サブアプリ情報を設定する
@applySubAppData = (subAppName) ->
  (req, res, next) ->
    subAppViewRoot = "#{conf.root}/views/apps/#{subAppName}"

    req.subApp =
      name: subAppName
      root: "#{root}/apps/#{subAppName}"
      viewRoot: subAppViewRoot

    res.subApp = {}

    res.subApp.render = _.bind(coreLib.bindPathRoot(subAppViewRoot, res.render), res)

    res.subApp.renderForm = (templatePath, locals={}) ->
      res.subApp.render templatePath, _.extend {
        # 値の保持用の フィールド名:値 のセット
        inputs: {}
        # ErrorReporter インスタンス
        error: null
      }, locals

    next()

# パス内の :id から指定モデルのドキュメントを抽出し req.doc へ格納する
# パス以外からも受け取れるようにする必要が出るかも
@applyObjectId = (model, options={}) ->
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

@requireObjectId = (model) =>
  @applyObjectId model, errorClass:Http404Error

@csrf = ->
  (req, res, next) ->
    if req.disableCsrf
      next()
    else
      express.csrf()(req, res, next)

@disableCsrf = ->
  (req, res, next) ->
    req.disableCsrf = true
    next()

@logServer = ->
  formatType = conf.server.logFormatType ?
    if conf.env is 'production' then 'combined' else 'dev'
  morgan formatType,
    skip: (req, res) ->
      switch conf.server.logFiltering
        when true
          return true
        when false
          return false
      urlData = urlModule.parse req.url
      /\.(css|gif|jpeg|jpg|js|png|woff)$/.test urlData.pathname

# API として JSON を返す
# どの state を使うかは厳密に決めず、ただ使えるものを限定するだけに留める
@JSON_API_STATES =
  success: 'success'
  invalid: 'invalid'
  error: 'error'
@jsonApi = ->
  (req, res, next) ->
    res.jsonApi = (data, options={}) ->
      options = _.extend {
        state: exports.JSON_API_STATES.success
        message: ''
      }, options

      unless options.state in _.values exports.JSON_API_STATES
        return next new Error "Invalid jsonApi state=`#{options.state}`"

      res.json
        data: data
        state: options.state
        message: options.message
    next()

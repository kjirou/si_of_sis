_ = require 'underscore'


#
# エラー報告クラス
#
# エラーを同一書式でまとめて表示用データへ加工する。
# 主に入力エラーへ使う想定である。
#
class ErrorReporter

  constructor: (options={}) ->

    # スタックされたエラー情報
    #
    # e.g.
    #
    #   [{
    #     key: 'email'
    #     message: 'Invalid email'
    #   }, {
    #     key: 'password'
    #     message: 'Password is required'
    #   }, {
    #     key: 'email'
    #     message: 'Duplicated email'
    #   }, ..]
    #
    @_errors = []

    # i18n 処理を行うためのフィルター or null
    # i18n 用モジュールの __ 関数を渡すことを想定している
    @_i18nFilter = null

    options = _.extend {
      i18n: null
    }, options

    @setI18nFilter options.i18n if options.i18n

  error: (key, message) ->
    @_errors.push { key:key, message:message }

  merge: (errorReporter) ->
    for error in errorReporter._errors
      @_errors.push error

  isErrorOcurred: -> @_errors.length > 0

  setI18nFilter: (@_i18nFilter) ->

  _applyI18n: (message) ->
    if @_i18nFilter then @_i18nFilter message else message

  # エラー情報を使い易い形に整形して返す
  #
  # Returns: e.g.
  #
  #   {
  #     email: [{
  #       key: 'email'
  #       msg: 'Invalid email'
  #     }, {
  #       key: 'email'
  #       msg: 'Duplicated email'
  #     }]
  #     password: [{
  #       key: 'password'
  #       msg: 'Password is required'
  #     }]
  #   }
  #
  report: ->
    errors = {}
    for err in @_errors
      unless errors[err.key]?
        errors[err.key] = []
      errors[err.key].push {
        key: err.key
        msg: @_applyI18n err.message
      }
    errors


module.exports = ErrorReporter

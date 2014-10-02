_ = require 'underscore'
validator = require 'validator'


validator.extend 'isGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num > threshold

validator.extend 'isLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num < threshold


# 各バリデーションに対応するデフォルトエラーメッセージ群
ERROR_MESSAGES =
  CONTAINS: 'Not contained'
  EQUALS: 'Not equal'
  IS_AFTER: 'Invalid date'
  IS_ALPHA: 'Invalid characters'
  IS_ASCII: 'Invalid characters'
  IS_BASE64: 'Invalid characters'
  IS_BEFORE: 'Invalid date'
  IS_BYTE_LENGTH: ''
  IS_CREDIT_CARD: 'Invalid credit card'
  IS_DATE: 'Not a date'
  IS_DIVISIBLE_BY: 'Not divisible'
  IS_EMAIL: 'Invalid email'
  IS_FLOAT: 'Invalid float'
  IS_FQDN: 'Invalid FQDN'
  IS_FULL_WIDTH: ''
  IS_GREATER_THAN: ''
  IS_HALF_WIDTH: ''
  IS_IN: 'Unexpected value or invalid argument'
  IS_INT: 'Invalid integer'
  IS_IP: 'Invalid IP'
  IS_ISBN: 'Invalid ISBN'
  IS_HEXADECIMAL: 'Invalid hexadecimal'
  IS_HEX_COLOR: 'Invalid hexcolor'
  IS_JSON: 'Invalid JSON'
  IS_LENGTH: 'String is not in range'
  IS_LESS_THAN: ''
  IS_LOWERCASE: 'Invalid characters'
  IS_MULTIBYTE: ''
  IS_NULL: 'String is not empty'
  IS_SURROGATE_PAIR: 'Invalid characters'
  IS_UPPERCASE: 'Invalid characters'
  IS_URL: 'Invalid URL'
  IS_UUID: 'Invalid UUID'
  IS_VARIABLE_WIDTH: ''
  MATCHES: ''


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

  set: (key, message) ->
    @_errors.push { key:key, message:message }

  hasOccured: -> @_errors.length > 0

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


module.exports =
  ERROR_MESSAGES: ERROR_MESSAGES
  ErrorReporter: ErrorReporter
  validator: validator

async = require 'async'
_ = require 'underscore'
_s = require 'underscore.string'
validator = require 'validator'


validator.extend 'isGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num > threshold

validator.extend 'isInvalid', -> false

validator.extend 'isLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num < threshold


# 各バリデーションに対応するデフォルトエラーメッセージ群
ERROR_MESSAGES =
  CONTAINS: 'Not contained'
  EQUALS: 'Not equal'
  IS_AFTER: 'Invalid date'
  IS_ALPHA: 'Invalid characters'
  IS_ALPHANUMERIC: 'Invalid characters'
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
  IS_INVALID: 'Invalid value'
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
  IS_NUMERIC: 'Invalid characters'
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

  merge: (errorReporter) ->
    for error in errorReporter._errors
      @_errors.push error

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


class Field

  constructor: (options={}) ->
    @options = _.extend {
      # 判定が複数ある場合に
      # false=不正な判定が発生したら終了する, true=継続して全てを判定する
      shouldCheckAll: false
    }, options

    @_checks = []

  _addCheck: (params) ->
    @_checks.push(_.extend {
      type: null
      args: null
      message: null
      validation: null
    }, params)

  # 定型バリデーションを定義する validator から、該当メソッドを抽出する
  _getTypicalValidation: (type) ->
    validator[type] ? null

  _getTypicalValidationOrError: (type) ->
    validation = @_getTypicalValidation type
    # toBoolean などのサニタイズ用メソッドやinitなどがあるのでチェックが不十分
    # いい対策もないので今のところはこれで良い
    unless _.isFunction validation
      throw new Error "validator.#{type} is not defined"
    validation

  # Examples:
  #  type('isEmail', 'It is not a email')
  #  type('isUrl')  // Use default error message
  #  type('isLength', [8, 12], 'It is not within 8 to 12')  // Pass args to validator
  type: (type, validationArgs=null, message=null) ->
    if _.isString validationArgs  # Apply overloading
      message = validationArgs
      validationArgs = null
    defaultMessageKey = _s.underscored(type).toUpperCase()  # 'isURL' -> 'IS_URL'
    @_getTypicalValidationOrError type
    @_addCheck {
      type: type
      args: validationArgs
      message: message ? ERROR_MESSAGES[defaultMessageKey] ? ERROR_MESSAGES.IS_INVALID
    }
    @

  custom: (validation) ->
    @_addCheck validation:validation
    @

  _validateTypically: (type, args, value) ->
    validation = @_getTypicalValidationOrError type
    isValid = validation.apply validator, [value].concat(args)
    throw new Error "validator.#{type} does not return a boolean" unless _.isBoolean isValid
    isValid

  # カスタムバリデーション関数を実行する
  _validateCustom: (validation, value, callback) ->
    # カスタムバリデーションの仕様とそのコールバックの仕様はここを参照
    #
    # カスタムバリデーションの定義例:
    #   validation = ({value}, callback) ->
    #     execYourAsyncProcess value, (e, someValue) ->
    #       if e
    #         callback e
    #       else if someValue is 'valid_value'
    #         callback null, {isValid:true}
    #       else
    #         callback null, {isValid:false, message:'Invalid value'}
    #
    validation {
      value
    }, (e, {
      # バリデーション結果, true or false
      isValid
      # バリデーション失敗時に表示するエラーメッセージ
      # String or Array or (null or undefined)
      message
    }={}) ->
      if e
        callback e, {}
      else
        unless _.isBoolean isValid
          callback new Error('Custom validation does not return a boolean'), {}
        else
          callback e, {
            isValid,
            errorMessages: if _.isString message
              [message]
            else if _.isArray message
              message.slice()
            else
              if isValid then [] else [ERROR_MESSAGES.IS_INVALID]
          }

  validate: (value, callback) ->
    self = @
    invalidResults = []
    addInvalidResult = (message) ->
      invalidResults.push message:message

    async.eachSeries @_checks, ({type, args, message, validation}, nextLoop) =>
      if self.options.shouldCheckAll is false and invalidResults.length > 0
        nextLoop()
      else if validation?
        @_validateCustom validation, value, (e, {isValid, errorMessages}) ->
          return nextLoop e if e
          unless isValid
            addInvalidResult errorMessage for errorMessage in errorMessages
          nextLoop()
      else
        try
          addInvalidResult message unless @_validateTypically(type, args ? [], value)
          nextLoop()
        catch e
          nextLoop e
    , (e) ->
      return callback e, {} if e
      callback null, {
        isValid: invalidResults.length is 0
        errorMessages: invalidResults.map (v) -> v.message
      }


# フィールドの集合を定義するフォームクラス
# 基本的には継承して使うことを意図している
class Form

  constructor: (fieldValues={}) ->
    @_fields = []
    @_fieldValues = {}
    @values fieldValues

  _hasField: (fieldName) ->
    for fieldData in @_fields
      return true if fieldName is fieldData.fieldName
    false

  # 特定のフィールドに紐付かないものも
  # 適当な名前を付けてカスタムバリデーションのみのフィールドとして定義する
  field: (fieldName, field) ->
    if @_hasField fieldName
      throw new Error "#{fieldName} is already defined"
    @_fields.push {fieldName, field}

  value: (fieldName, fieldValue) ->
    @_fieldValues[fieldName] = fieldValue

  values: (fieldValues) ->
    _.extend @_fieldValues, fieldValues

  validate: (callback) ->
    reporter = new ErrorReporter
    async.eachSeries @_fields, ({fieldName, field}, nextLoop) =>
      fieldValue = if fieldName of @_fieldValues then @_fieldValues[fieldName] else ''
      field.validate fieldValue, (e, {isValid, errorMessages}) ->
        if e
          nextLoop e if e
        else
          unless isValid
            for errorMessage in errorMessages
              reporter.set fieldName, errorMessage
          nextLoop()
    , (e) ->
      return callback e, {} if e
      callback null, {
        isValid: not reporter.hasOccured()
        errors: reporter.report()
        reporter: reporter
      }


module.exports =
  ERROR_MESSAGES: ERROR_MESSAGES
  ErrorReporter: ErrorReporter
  Field: Field
  Form: Form
  validator: validator

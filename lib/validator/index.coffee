async = require 'async'
_ = require 'underscore'
validator = require 'validator'

defaultErrorMessages = require './default-error-messages'
ErrorReporter = require './error-reporter'


validator.extend 'isGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num > threshold

validator.extend 'isInvalid', -> false

validator.extend 'isLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num < threshold

validator.extend 'isRequired', (str) ->
  str.length > 0


class Field

  constructor: (options={}) ->
    @_checks = []
    @options = _.extend {
      # 空文字列の場合に入力チェックを行わない
      passIfEmpty: false
      # 判定が複数ある場合に
      # false=不正な判定が発生したら終了する, true=継続して全てを判定する
      shouldCheckAll: false
    }, options

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
    @_getTypicalValidationOrError type
    @_addCheck {
      type: type
      args: validationArgs
      message: message ? defaultErrorMessages[type] ? defaultErrorMessages.isInvalid
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
              if isValid then [] else [defaultErrorMessages.isInvalid]
          }

  validate: (value, callback) ->
    self = @
    invalidResults = []
    addInvalidResult = (message) ->
      invalidResults.push message:message

    async.eachSeries @_checks, ({type, args, message, validation}, nextLoop) =>
      if (
        self.options.passIfEmpty and value is '' or
        self.options.shouldCheckAll is false and invalidResults.length > 0
      )
        return nextLoop()
      else if validation?
        @_validateCustom validation, value, (e, {isValid, errorMessages}) ->
          return nextLoop e if e
          unless isValid
            addInvalidResult errorMessage for errorMessage in errorMessages
          return nextLoop()
      else
        try
          addInvalidResult message unless @_validateTypically(type, args ? [], value)
          return nextLoop()
        catch e
          return nextLoop e
    , (e) ->
      return callback e, {} if e
      callback null, {
        isValid: invalidResults.length is 0
        errorMessages: invalidResults.map (v) -> v.message
      }


# フィールドの集合を定義するフォームクラス
# 基本的には継承して使うことを意図している
class Form

  constructor: (fieldValues={}, options={}) ->
    @_fields = []
    @resetValues()
    @options = _.extend {
      shouldCheckAll: true
    }, options
    @values fieldValues

  getField: (fieldName) ->
    for fieldData in @_fields
      return fieldData.field if fieldName is fieldData.fieldName
    null
  getFieldOrError: (fieldName) ->
    @getField(fieldName) or throw new Error("#{fieldName} is not defined")

  # 特定のフィールドに紐付かないものも
  # 適当な名前を付けてカスタムバリデーションのみのフィールドとして定義する
  field: (fieldName, field) ->
    if @getField fieldName
      throw new Error "#{fieldName} is already defined"
    @_fields.push {fieldName, field}

  value: (fieldName, fieldValue) ->
    @_fieldValues[fieldName] = fieldValue

  values: (fieldValues) ->
    _.extend @_fieldValues, fieldValues

  resetValues: -> @_fieldValues = {}

  validate: (callback) ->
    reporter = new ErrorReporter
    async.eachSeries @_fields, ({fieldName, field}, nextLoop) =>
      # バリデーションフィールドに定義されている値が存在しない場合
      unless fieldName of @_fieldValues
        # 空文字列の入力とみなす
        if @options.shouldCheckAll
          fieldValue = ''
        # バリデーションを無視する
        else
          return nextLoop()
      else
        fieldValue = @_fieldValues[fieldName]

      field.validate fieldValue, (e, {isValid, errorMessages}) ->
        if e
          nextLoop e if e
        else
          unless isValid
            for errorMessage in errorMessages
              reporter.error fieldName, errorMessage
          nextLoop()
    , (e) ->
      return callback e, {} if e
      callback null, {
        isValid: not reporter.isErrorOcurred()
        errors: reporter.report()
        reporter: reporter
      }


module.exports =
  defaultErrorMessages: defaultErrorMessages
  ErrorReporter: ErrorReporter
  Field: Field
  Form: Form
  validator: validator

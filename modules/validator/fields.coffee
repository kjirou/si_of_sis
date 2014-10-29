async = require 'async'
_ = require 'underscore'


class Field

  @defaultErrorMessages: undefined
  @validator: undefined

  constructor: (options={}) ->
    @_checks = []
    @options = _.extend {
      # 空文字列の場合に入力チェックを行わない
      passIfEmpty: false
      # 判定が複数ある場合に
      # false=不正な判定が発生したら終了する, true=継続して全てを判定する
      shouldCheckAll: false
    }, options

  getValidator: -> @constructor.validator
  getDefaultErrorMessages: -> @constructor.defaultErrorMessages

  _addCheck: (params) ->
    @_checks.push(_.extend {
      type: null
      args: null
      message: null
      validation: null
    }, params)

  # 定型バリデーションを定義する validator から、該当メソッドを抽出する
  _getTypicalValidation: (type) ->
    @getValidator()[type] ? null

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
      message: message ?
        @getDefaultErrorMessages()[type] ?
        @getDefaultErrorMessages().isInvalid
    }
    @

  custom: (validation) ->
    @_addCheck validation:validation
    @

  _validateTypically: (type, args, value) ->
    validation = @_getTypicalValidationOrError type
    isValid = validation.apply @getValidator(), [value].concat(args)
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
    }={}) =>
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
              if isValid then [] else [@getDefaultErrorMessages().isInvalid]
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


module.exports = (validator, defaultErrorMessages) ->
  Field.validator = validator
  Field.defaultErrorMessages = defaultErrorMessages
  {Field}

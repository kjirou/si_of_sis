async = require 'async'
_ = require 'underscore'


# フィールドの集合を定義するフォームクラス
# 基本的には継承して使うことを意図している
class Form

  @ErrorReporter: undefined

  constructor: (fieldValues={}, options={}) ->
    @_fields = []
    @resetValues()
    @options = _.extend {
      shouldCheckAll: true
    }, options
    @values fieldValues

  getErrorReporter: -> @constructor.ErrorReporter

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
    reporter = new (@getErrorReporter())
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


module.exports = (ErrorReporter) ->
  Form.ErrorReporter = ErrorReporter
  {Form}

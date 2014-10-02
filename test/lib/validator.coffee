assert = require 'power-assert'
_ = require 'underscore'

{ERROR_MESSAGES, ErrorReporter, validator} = require 'lib/validator'


describe 'validator Lib', ->

  it 'Module definition', ->
    assert typeof validator is 'object'
    assert typeof ERROR_MESSAGES is 'object'
    assert _.size(ERROR_MESSAGES) > 0
    assert typeof ErrorReporter is 'function'


  describe 'validator Extensions', ->

    it 'isGreaterThan', ->
      assert typeof validator.isGreaterThan is 'function'
      assert validator.isGreaterThan '3', 2.9
      assert validator.isGreaterThan('3', 3) is false
      assert validator.isGreaterThan('3.1', 3)

    it 'isLessThan', ->
      assert typeof validator.isLessThan is 'function'
      assert validator.isLessThan '2.9', 3
      assert validator.isLessThan('3', 3) is false
      assert validator.isLessThan '3', 3.1


  describe 'ErrorReporter Class', ->

    it 'Create a instance', ->
      reporter = new ErrorReporter
      assert reporter instanceof ErrorReporter

    it 'エラーを格納し、エラー存否判定と報告ができる', ->
      reporter = new ErrorReporter
      assert reporter.hasOccured() is false
      reporter.set 'foo', 'Invalid foo'
      assert reporter.hasOccured()
      reporter.set 'bar', 'Invalid bar'
      reporter.set 'foo', 'Required foo'
      assert.deepEqual reporter.report(), {
        foo: [
          { key:'foo', msg:'Invalid foo' }
          { key:'foo', msg:'Required foo' }
        ]
        bar: [
          { key:'bar', msg:'Invalid bar' }
        ]
      }

    it 'i18n用のフィルターを設定できる', ->
      reporter = new ErrorReporter
      reporter.set 'foo', 'Invalid foo'
      reporter.setI18nFilter (msg) -> msg.toUpperCase()
      assert.deepEqual reporter.report(), {
        foo: [{
          key: 'foo'
          msg: 'INVALID FOO'
        }]
      }

      # コンストラクタからも設定できる
      reporter = new ErrorReporter({i18n: (msg) -> msg.toLowerCase()})
      reporter.set 'foo', 'Invalid foo'
      assert.deepEqual reporter.report(), {
        foo: [{
          key: 'foo'
          msg: 'invalid foo'
        }]
      }

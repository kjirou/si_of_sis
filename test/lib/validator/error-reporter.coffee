assert = require 'power-assert'

{ErrorReporter} = require 'modules/validator'


describe 'ErrorReporter Class', ->

  it 'Create a instance', ->
    reporter = new ErrorReporter
    assert reporter instanceof ErrorReporter

  it 'エラーを格納し、エラー存否判定と報告ができる', ->
    reporter = new ErrorReporter
    assert reporter.isErrorOcurred() is false
    reporter.error 'foo', 'Invalid foo'
    assert reporter.isErrorOcurred()
    reporter.error 'bar', 'Invalid bar'
    reporter.error 'foo', 'Required foo'
    assert.deepEqual reporter.report(), {
      foo: [
        { key:'foo', msg:'Invalid foo' }
        { key:'foo', msg:'Required foo' }
      ]
      bar: [
        { key:'bar', msg:'Invalid bar' }
      ]
    }

  it 'merge', ->
    reporter = new ErrorReporter
    reporter.error 'foo', 'Invalid foo'
    another = new ErrorReporter
    another.error 'bar', 'Invalid bar'
    another.error 'foo', 'Invalid foo2'
    reporter.merge another
    assert.deepEqual reporter.report(), {
      foo: [
        { key:'foo', msg:'Invalid foo' }
        { key:'foo', msg:'Invalid foo2' }
      ]
      bar: [
        { key:'bar', msg:'Invalid bar' }
      ]
    }

  it 'i18n用のフィルターを設定できる', ->
    reporter = new ErrorReporter
    reporter.error 'foo', 'Invalid foo'
    reporter.setI18nFilter (msg) -> msg.toUpperCase()
    assert.deepEqual reporter.report(), {
      foo: [{
        key: 'foo'
        msg: 'INVALID FOO'
      }]
    }

    # コンストラクタからも設定できる
    reporter = new ErrorReporter({i18n: (msg) -> msg.toLowerCase()})
    reporter.error 'foo', 'Invalid foo'
    assert.deepEqual reporter.report(), {
      foo: [{
        key: 'foo'
        msg: 'invalid foo'
      }]
    }

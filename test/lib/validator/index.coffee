{Schema} = require 'mongoose'
assert = require 'power-assert'
_ = require 'underscore'

testHelper = require 'helpers/test'
{createValidator, DEFAULT_ERROR_MESSAGES, ErrorReporter, Field, Form, validator} = require 'lib/validator'


describe 'validator Lib', ->

  it 'Module definition', ->
    assert typeof createValidator is 'function'
    assert typeof DEFAULT_ERROR_MESSAGES is 'object'
    assert _.size(DEFAULT_ERROR_MESSAGES) > 0
    assert typeof ErrorReporter is 'function'
    assert typeof Field is 'function'
    assert typeof Form is 'function'
    assert typeof validator is 'object'


  describe 'createValidator', ->

    it 'createValidator', ->
      result = createValidator { validator:'isInt' }
      assert.strictEqual(typeof result.validator, 'function')
      assert.strictEqual result.msg, DEFAULT_ERROR_MESSAGES.isInt
      assert result.validator('1') is true
      assert result.validator('1.1') is false
      assert result.validator('') is false
      # message 設定
      result = createValidator { validator:'isInt', message:'FOO' }
      assert.strictEqual result.msg, 'FOO'
      # passIfEmpty 設定
      result = createValidator { validator:'isInt', passIfEmpty:true }
      assert result.validator('1') is true
      assert result.validator('1.1') is false
      assert result.validator('') is true
      # passIfNull 設定
      result = createValidator { validator:'isInt', passIfNull:true }
      assert result.validator('1') is true
      assert result.validator('') is false
      assert result.validator(null) is true
      assert result.validator(undefined) is true
      # arguments 設定
      result = createValidator { validator:'isLength', arguments:[4, 8] }
      assert result.validator('1234') is true
      assert result.validator('12345678') is true
      assert result.validator('123') is false
      assert result.validator('123456789') is false

    it 'mongoose Schema へ適用できる', (done) ->
      schema = new Schema {
        email:
          type: String
          validate: [
            createValidator { validator:'isEmail' }
          ]
      }
      testHelper.createTestModel schema, (e, Test) ->
        doc = new Test
        doc.email = 'fooexamplecom'
        doc.save (e) ->
          assert e and e.name is 'ValidationError'
          done()

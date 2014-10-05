assert = require 'power-assert'
_ = require 'underscore'

{ERROR_MESSAGES, ErrorReporter, Field, Form, validator} = require 'lib/validator'


describe 'validator Lib', ->

  it 'Module definition', ->
    assert typeof validator is 'object'
    assert typeof ERROR_MESSAGES is 'object'
    assert _.size(ERROR_MESSAGES) > 0
    assert typeof ErrorReporter is 'function'


  describe 'validator Extensions', ->

    it 'isInvalid', ->
      assert typeof validator.isInvalid is 'function'
      assert validator.isInvalid() is false

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

    it 'isRequired', ->
      assert typeof validator.isInvalid is 'function'
      assert validator.isRequired 'a'
      assert validator.isRequired('') is false


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

    it 'merge', ->
      reporter = new ErrorReporter
      reporter.set 'foo', 'Invalid foo'
      another = new ErrorReporter
      another.set 'bar', 'Invalid bar'
      another.set 'foo', 'Invalid foo2'
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


  describe 'Field Class', ->

    it 'Class definition', ->
      assert typeof Field is 'function'

    it 'Create a instance', ->
      field = new Field
      assert field instanceof Field

    it 'type', ->
      # 基本的な使い方
      field = new Field
      field.type 'isEmail', 'It is not a email'
      assert.deepEqual field._checks, [
        {type:'isEmail', args:null, message:'It is not a email', validation:null}
      ]
      # デフォルトメッセージを使っている
      field = new Field
      field.type 'isEmail'
      assert.deepEqual field._checks, [
        {type:'isEmail', args:null, message:ERROR_MESSAGES.IS_EMAIL, validation:null}
      ]
      # validator 側で使用する引数を設定できる
      # また、引数 3 つのパターンで定義できる
      field = new Field
      field.type 'isLength', [8, 12], 'It is not within 8 to 12'
      assert.deepEqual field._checks, [
        {type:'isLength', args:[8, 12], message:'It is not within 8 to 12', validation:null}
      ]
      # 存在しないバリデーションの場合はエラーを投げる
      field = new Field
      assert.throws ->
        field.type 'fooBarBaz'
      , /fooBarBaz/

    it 'custom', ->
      field = new Field
      validation = -> true
      field.custom validation
      assert.deepEqual field._checks, [
        {type:null, args:null, message:null, validation:validation}
      ]

    it 'typeとcustomをメソッドチェインして複数定義できる', ->
      field = new Field
      field
        .type 'isLength', [4, 8]
        .custom -> true
        .type 'isEmail'
      assert field._checks.length is 3

    it '_validateTypically', ->
      field = new Field
      assert field._validateTypically('isEmail', [], 'foo@example.com') is true
      assert field._validateTypically('isEmail', [], 'fooexamplecom') is false
      assert field._validateTypically('isLength', [4, 8], '1234') is true
      assert field._validateTypically('isLength', [4, 8], '123') is false
      assert field._validateTypically('isLength', [4, 8], '123456789') is false
      assert field._validateTypically('isLength', [4], '123456789') is true
      # 存在しない
      assert.throws ->
        field._validateTypically 'fooBarBaz'
      , /fooBarBaz/
      # Boolean を返さない
      assert.throws ->
        field._validateTypically 'toInt', [], '1'
      , /toInt/

    it '_validateCustom', (done) ->
      # 基本的な使い方
      validation = ({value}, callback) ->
        if value is 'errored'
          callback new Error
        else if value is 'foo'
          callback null, {isValid:true}
        else
          callback null, {isValid:false, message:'Value is not foo'}
      field = new Field
      # 入力が正しい
      field._validateCustom validation, 'foo', (e, {isValid, errorMessages}) ->
        assert isValid is true
        assert.deepEqual errorMessages, []
        # 入力が誤っている
        field = new Field
        field._validateCustom validation, 'bar', (e, {isValid, errorMessages}) ->
          assert isValid is false
          assert.deepEqual errorMessages, ['Value is not foo']
          # 不慮のエラーが発生した
          field = new Field
          field._validateCustom validation, 'errored', (e) ->
            assert e instanceof Error
            done()

    it '_validateCustomに渡す処理がisValidを正しく返さない場合はエラーが入る', (done) ->
      validation = ({value}, callback) ->
        callback null, {isValid:1}
      field = new Field
      field._validateCustom validation, '', (e) ->
        assert e instanceof Error
        assert /boolean/.test e.message
        done()

    it '_validateCustomに渡す処理がmessageを返さない場合はデフォルトメッセージが入る', (done) ->
      validation = ({value}, callback) ->
        callback null, {isValid:false}
      field = new Field
      field._validateCustom validation, '', (e, {isValid, errorMessages}) ->
        assert not e
        assert isValid is false
        assert.deepEqual errorMessages, [ERROR_MESSAGES.IS_INVALID]
        done()


    describe 'validate', ->

      it '定型バリデーションが行える', (done) ->
        field = new Field
        field.type 'isEmail'
        field.type 'isLength', [10]
        # 入力が正しい
        field.validate 'foo@example.com', (e1, {isValid, errorMessages}) ->
          assert not e1
          assert isValid is true
          assert.deepEqual errorMessages, []
          # Email 形式ではなかった
          field.validate 'fooexamplecom', (e2, {isValid, errorMessages}) ->
            assert not e2
            assert isValid is false
            assert.deepEqual errorMessages, [ERROR_MESSAGES.IS_EMAIL]
            # 文字数が足りなかった
            field.validate 'f@e.com', (e3, {isValid, errorMessages}) ->
              assert not e3
              assert isValid is false
              assert.deepEqual errorMessages, [ERROR_MESSAGES.IS_LENGTH]
              # Email ではなく文字数も足りなかったが shouldCheckAll=false なのでエラー行数は 1
              field.validate 'fecom', (e4, {isValid, errorMessages}) ->
                assert not e4
                assert isValid is false
                assert.deepEqual errorMessages, [
                  ERROR_MESSAGES.IS_EMAIL
                ]
                # Email ではなく文字数も足りない、shouldCheckAll=true なのでエラー行数は 2
                field.options.shouldCheckAll = true
                field.validate 'fecom', (e5, {isValid, errorMessages}) ->
                  assert not e5
                  assert isValid is false
                  assert.deepEqual errorMessages, [
                    ERROR_MESSAGES.IS_EMAIL
                    ERROR_MESSAGES.IS_LENGTH
                  ]
                  done()

      it '定型バリデーションでBooleanを返さないtypeを指定したらエラーを返す', (done) ->
        field = new Field
        field.type 'isEmail'
        field.type 'toInt'
        field.validate 'foo@example.com', (e, {isValid, errorMessages}) ->
          assert e instanceof Error
          /toInt/.test e.message
          done()

      it 'カスタムバリデーションが行える', (done) ->
        field = new Field
        field.custom ({value}, callback) ->
          if value is 'foo'
            callback null, {isValid:true}
          else
            callback null, {isValid:false}
        # 入力が正しい
        field.validate 'foo', (e, {isValid, errorMessages}) ->
          assert not e
          assert isValid is true
          assert.deepEqual errorMessages, []
          # 入力が誤り
          field.validate 'bar', (e, {isValid, errorMessages}) ->
            assert not e
            assert isValid is false
            assert.deepEqual errorMessages, [ERROR_MESSAGES.IS_INVALID]
            done()

      it '定型とカスタムバリデーションが混在している', (done) ->
        field = new Field shouldCheckAll:true
        field.type 'isAlphanumeric'
        field.type 'isLength', [6, 12]
        field.custom ({value}, callback) ->
          setTimeout ->
            if /^\d/.test value  # 先頭一文字が数値はNG
              callback null, {isValid:false, message:'Can not set numeric string as prefix'}
            else
              callback null, {isValid:true}
          , 1
        # 入力が正しい
        field.validate 'abc123', (e, {isValid, errorMessages}) ->
          assert not e
          assert isValid is true
          assert.deepEqual errorMessages, []
          # 入力が 1 点誤り
          field.validate 'abc123_', (e, {isValid, errorMessages}) ->
            assert not e
            assert isValid is false
            assert.deepEqual errorMessages, [ERROR_MESSAGES.IS_ALPHANUMERIC]
            # 入力が 2 点誤り
            field.validate 'ab12_', (e, {isValid, errorMessages}) ->
              assert isValid is false
              assert.deepEqual errorMessages, [
                ERROR_MESSAGES.IS_ALPHANUMERIC
                ERROR_MESSAGES.IS_LENGTH
              ]
              # 入力が 3 点誤り
              field.validate '1ab2_', (e, {isValid, errorMessages}) ->
                assert isValid is false
                assert.deepEqual errorMessages, [
                  ERROR_MESSAGES.IS_ALPHANUMERIC
                  ERROR_MESSAGES.IS_LENGTH
                  'Can not set numeric string as prefix'
                ]
                done()


  describe 'Form Class', ->

    it 'Class definition', ->
      assert typeof Form is 'function'

    it 'Create a instance', ->
      form = new Form
      assert form instanceof Form

    it 'field', ->
      form = new Form
      form.field 'foo', new Field
      form.field 'bar', new Field
      assert form._fields.length is 2
      assert.throws ->
        form.field 'foo', new Field
      , /foo/

    it 'value / values', ->
      form = new Form
      form.value 'foo', 'foo_value'
      form.value 'bar', 'bar_value'
      assert.deepEqual form._fieldValues, {
        foo: 'foo_value'
        bar: 'bar_value'
      }
      form.values {
        bar: 'bar_value_2'
        baz: 'baz_value'
      }
      assert.deepEqual form._fieldValues, {
        foo: 'foo_value'
        bar: 'bar_value_2'
        baz: 'baz_value'
      }
      # コンストラクタで values を設定
      form = new Form(x:'1', y:'2')
      assert.deepEqual form._fieldValues, {x:'1', y:'2'}


    describe 'validate', ->

      it '定型フィールドのみのフォームが正しくバリデーションできる', (done) ->
        emailField = new Field
        emailField.type 'isEmail'

        passwordField = new Field
        passwordField.type 'isAlphanumeric'
        passwordField.type 'isLength', [8, 16]

        form = new Form
        form.field 'email', emailField
        form.field 'password', passwordField

        # 入力が正しい
        form.values {
          email: 'foo@example.com'
          password: 'abcd1234'
        }
        form.validate (e, {isValid, reporter, errors}) ->
          assert isValid is true
          assert reporter instanceof ErrorReporter
          assert _.size(errors) is 0
          # 入力が誤り
          form.values {
            email: 'fooexamplecom'
            password: '_abcd1234'
          }
          form.validate (e, {isValid, reporter, errors}) ->
            assert not e
            assert isValid is false
            assert reporter instanceof ErrorReporter
            assert _.size(errors) is 2
            done()

      it 'フォームを継承してサブフォームを定義できる', (done) ->
        class FooForm extends Form
          constructor: ->
            super
            @field 'site_url',((new Field)
              .type 'isURL'
            )
            @field 'views',((new Field)
              .type 'isInt'
            )
        # 入力が正しい
        form = new FooForm {
          site_url: 'http://example.com'
          views: '100'
        }
        form.validate (e, {isValid}) ->
          assert not e
          assert isValid is true
          # 入力が一部誤っている
          form.value 'views', ''
          form.validate (e, {isValid, errors}) ->
            assert not e
            assert isValid is false
            assert _.size(errors) is 1
            done()

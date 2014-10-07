assert = require 'power-assert'
_ = require 'underscore'

{defaultErrorMessages, ErrorReporter, Field, Form, validator} = require 'lib/validator'


describe 'validator Lib', ->

  it 'Module definition', ->
    assert typeof validator is 'object'
    assert typeof defaultErrorMessages is 'object'
    assert _.size(defaultErrorMessages) > 0
    assert typeof ErrorReporter is 'function'


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
        {type:'isEmail', args:null, message:defaultErrorMessages.isEmail, validation:null}
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
        assert.deepEqual errorMessages, [defaultErrorMessages.isInvalid]
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
            assert.deepEqual errorMessages, [defaultErrorMessages.isEmail]
            # 文字数が足りなかった
            field.validate 'f@e.com', (e3, {isValid, errorMessages}) ->
              assert not e3
              assert isValid is false
              assert.deepEqual errorMessages, [defaultErrorMessages.isLength]
              # Email ではなく文字数も足りなかったが shouldCheckAll=false なのでエラー行数は 1
              field.validate 'fecom', (e4, {isValid, errorMessages}) ->
                assert not e4
                assert isValid is false
                assert.deepEqual errorMessages, [
                  defaultErrorMessages.isEmail
                ]
                # Email ではなく文字数も足りない、shouldCheckAll=true なのでエラー行数は 2
                field.options.shouldCheckAll = true
                field.validate 'fecom', (e5, {isValid, errorMessages}) ->
                  assert not e5
                  assert isValid is false
                  assert.deepEqual errorMessages, [
                    defaultErrorMessages.isEmail
                    defaultErrorMessages.isLength
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
            assert.deepEqual errorMessages, [defaultErrorMessages.isInvalid]
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
            assert.deepEqual errorMessages, [defaultErrorMessages.isAlphanumeric]
            # 入力が 2 点誤り
            field.validate 'ab12_', (e, {isValid, errorMessages}) ->
              assert isValid is false
              assert.deepEqual errorMessages, [
                defaultErrorMessages.isAlphanumeric
                defaultErrorMessages.isLength
              ]
              # 入力が 3 点誤り
              field.validate '1ab2_', (e, {isValid, errorMessages}) ->
                assert isValid is false
                assert.deepEqual errorMessages, [
                  defaultErrorMessages.isAlphanumeric
                  defaultErrorMessages.isLength
                  'Can not set numeric string as prefix'
                ]
                done()

      it 'passIfEmptyオプション', (done) ->
        field = new Field {passIfEmpty:true}
        field.type 'isEmail'
        field.validate '', (e, {isValid, errorMessages}) ->
          assert isValid is true
          done()

      it 'Fieldを継承できる', (done) ->
        field = new class extends Field
          constructor: ->
            super
            @type 'isEmail'
        field.validate 'fooexamplecom', (e, {isValid, errorMessages}) ->
          assert isValid is false
          assert.deepEqual errorMessages, [defaultErrorMessages.isEmail]
          # コンストラクタ引数が有効である
          class FooField extends Field
          field = new FooField {passIfEmpty:true, shouldCheckAll:true}
          assert field.options.passIfEmpty is true
          assert field.options.shouldCheckAll is true
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

    it 'getField / getFieldOrError', ->
      form = new Form
      form.field 'foo', new Field
      assert form.getField('foo')
      assert form.getField('bar') is null
      assert form.getFieldOrError('foo')
      assert.throws ->
        form.getFieldOrError 'baz'
      , /baz/

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
            # shouldCheckAll オプションが false だと存在しないフィールドを無視する
            form.options.shouldCheckAll = false
            form.resetValues()
            form.values {
              email: 'foo@example.com'
            }
            form.validate (e, {isValid, reporter, errors}) ->
              assert isValid is true
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

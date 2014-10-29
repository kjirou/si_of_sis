assert = require 'power-assert'
_ = require 'underscore'

{ErrorReporter, Field, Form} = require 'modules/validator'


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

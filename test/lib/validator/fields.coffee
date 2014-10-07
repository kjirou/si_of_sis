assert = require 'power-assert'

{defaultErrorMessages, Field} = require 'lib/validator'


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

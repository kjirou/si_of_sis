_ = require 'lodash'
mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
assert = require 'power-assert'

{GameDate} = require 'lib/game-date'
databaseHelper = require 'helpers/database'
{createTestModel} = require 'helpers/test'
{definePlugins, plugins} = require 'lib/mongoose-plugins'


describe 'mongoose-plugins Lib', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it 'core Plugin', (done) ->
    schema = new Schema {
      otherModel: Schema.Types.ObjectId
    }
    schema.plugin plugins.core
    createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      # プラグインで付与したメソッドがある
      assert typeof doc.assertPopulated is 'function'
      assert typeof Test.queryOneById is 'function'
      # assertPopulated
      assert.throws ->
        doc.assertPopulated 'otherModel'
      , /otherModel/
      # _id を固定にして 1 行保存する
      objectId = ObjectId ('0' for i in [0..23]).join('')
      testObj = _.extend new Test, { _id:objectId }
      testObj.save (e) ->
        # その 1 行を findOneById で取得できる
        Test.findOneById objectId, (e, doc) ->
          return done e if e
          assert doc
          assert doc._id.toString() is objectId.toString()
          # 不正な _id 文字列指定の場合は null を返す
          Test.findOneById 'invalid_object_id', (e, doc) ->
            return done e if e
            assert doc is null
            done()

  it 'createdAt Plugin', (done) ->
    schema = new Schema
    schema.plugin plugins.createdAt
    createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        return done e if e
        # 保存元オブジェクトにも設定されている
        assert doc.created_at instanceof Date
        Test.findOne (e, doc_) ->
          return done e if e
          # 再抽出したドキュメントにも保存されている
          assert doc_.created_at instanceof Date
          # 保存時と同じ時間である
          assert doc_.created_at.getTime() is doc.created_at.getTime()
          # 50ms 後に再抽出して更新しても created_at は更新されていない
          setTimeout ->
            Test.findOne {_id:doc_._id}, (e, doc__) ->
              return done e if e
              doc__.save (e) ->
                return done e if e
                assert doc__.created_at.getTime() is doc_.created_at.getTime()
                done()
          , 50

  it 'updatedAt Plugin', (done) ->
    schema = new Schema
    schema.plugin plugins.updatedAt
    createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        # 保存元オブジェクトにも設定されている
        assert doc.updated_at instanceof Date
        Test.findOne (e, doc_) ->
          return done e if e
          # 再抽出したドキュメントにも保存されている
          assert doc_.updated_at instanceof Date
          # 保存時と同じ時間である
          assert doc_.updated_at.getTime() is doc.updated_at.getTime()
          # 50ms 後に再抽出して更新すると時間が進んでいる
          setTimeout ->
            Test.findOne {_id:doc_._id}, (e, doc__) ->
              return done e if e
              doc__.save (e) ->
                return done e if e
                assert doc__.updated_at.getTime() > doc_.updated_at.getTime()
                done()
          , 50

  it 'createdAt/updatedAtが連携している', (done) ->
    schema = new Schema
    schema.plugin plugins.createdAt
    schema.plugin plugins.updatedAt
    createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test
      doc.save (e) ->
        return done e if e
        # 保存元オブジェクトには時間が両方設定され、オブジェクトの参照も同じである
        assert doc.created_at instanceof Date
        assert doc.updated_at instanceof Date
        assert doc.created_at is doc.updated_at
        # 50ms 後に再抽出して更新するとupdated_atのみに変更がある
        setTimeout ->
          Test.findOne (e, doc_) ->
            return done e if e
            doc_.save (e) ->
              return done e if e
              assert doc_.updated_at.getTime() > doc_.created_at.getTime()
              done()
        , 50

  it 'gameDates', (done) ->
    schema = new Schema {
      raw_foo: Number
      raw_bar: Number
      raw_baz: Number
      raw_none: Number
    }
    schema.plugin plugins.gameDates,
      map:
        raw_foo: 'foo'
        raw_bar: 'bar'
        raw_notexists: 'notexists'
    createTestModel schema, (e, Test) ->
      return done e if e
      doc = new Test {
        raw_foo: 6
        raw_bar: null
        raw_baz: 1
      }
      assert doc.foo instanceof GameDate
      assert.deepEqual doc.foo.toArray(), [0, 1, 2]
      assert doc.bar is null
      assert doc.baz is undefined  # プラグインが反映されていない
      assert doc.notexists is null  # フォールド自体が未定義
      done()

  it 'definePlugins', (done) ->
    schema = new Schema {
      raw_foo: String
    }
    definePlugins schema, 'core', ['gameDates', map: raw_foo: 'foo']
    createTestModel schema, (e, Test) ->
      assert Test.queryOneById typeof 'function'
      doc = new Test
      assert 'foo' of doc
      done()


  describe 'consumable', ->

    it 'Methods exist', (done) ->
      schema = new Schema {
        foo: Number
        bar:
          x: Number
            y: Number
          hoge_fuga: Number
        baz_qux: Number
        a_b: Number
      }
      plugins.consumable schema, current: 'foo', max: 10
      plugins.consumable schema, current: 'bar.x.y', max: 10
      plugins.consumable schema, current: 'bar.hoge_fuga', max: 10
      plugins.consumable schema, current: 'baz_qux', max: 10
      plugins.consumable schema, current: 'a_b', max: 10

      createTestModel schema, (e, Test) ->
        doc = new Test
        assert typeof doc.consumeFoo is 'function'
        assert typeof doc.consumeFooTillMin is 'function'
        assert typeof doc.canConsumeFoo is 'function'
        assert typeof doc.supplyFoo is 'function'
        assert typeof doc.supplyFooByRate is 'function'
        assert typeof doc.supplyFooFully is 'function'
        assert typeof doc.consumeBarXY is 'function'
        assert typeof doc.consumeBarHogeFuga is 'function'
        assert typeof doc.consumeBazQux is 'function'
        assert typeof doc.consumeAB is 'function'
        done()

    it '生成された各メソッドが動く', (done) ->
      schema = new Schema {
        foo:
          type: Number
          default: 0
      }
      plugins.consumable schema, current: 'foo', max: 10

      createTestModel schema, (e, Test) ->
        doc = new Test
        # 8 を供給する
        doc.supplyFoo 8
        assert.strictEqual doc.foo, 8
        # 最大値以上を供給するが最大値に収まっている
        doc.supplyFoo 3
        assert.strictEqual doc.foo, 10
        # 消費可能判定が適切
        assert doc.canConsumeFoo 10
        assert not doc.canConsumeFoo 10.1
        # 消費できる
        doc.consumeFoo 8
        assert.strictEqual doc.foo, 2
        # 最小値を下回る場合は消費出来ずエラーになる
        assert.throws ->
          doc.consumeFoo 3
        , /3.+2/
        # TillMin 付きは最小値まで消費すればエラーにならない
        doc.consumeFooTillMin 1
        assert.strictEqual doc.foo, 1
        doc.consumeFooTillMin 2
        assert.strictEqual doc.foo, 0
        # 割合で供給できる
        doc.supplyFooByRate 0.2
        assert.strictEqual doc.foo, 2
        # 割合供給はデフォルト切り上げ
        doc.supplyFooByRate 0.01
        assert.strictEqual doc.foo, 3
        # 端数オプション
        doc.supplyFooByRate 0.01, fraction:'ceil'
        assert.strictEqual doc.foo, 4
        doc.supplyFooByRate 0.099, fraction:'floor'
        assert.strictEqual doc.foo, 4
        # 満タンまで供給
        doc.supplyFooFully()
        assert.strictEqual doc.foo, 10
        done()

    it 'minが0以上', (done) ->
      schema = new Schema {
        foo:
          type: Number
          default: 5
      }
      plugins.consumable schema, current: 'foo', min: 1, max: 10
      createTestModel schema, (e, Test) ->
        doc = new Test
        doc.consumeFoo 3
        assert.strictEqual doc.foo, 2
        assert doc.canConsumeFoo 1
        assert not doc.canConsumeFoo 2
        doc.consumeFooTillMin 99
        assert.strictEqual doc.foo, 1
        done()

    it 'maxが別フィールドを参照', (done) ->
      schema = new Schema {
        foo:
          type: Number
          default: 5
        max_foo:
          type: Number
          default: 20
      }
      plugins.consumable schema, current: 'foo', max: 'max_foo'
      createTestModel schema, (e, Test) ->
        doc = new Test
        doc.supplyFoo 99
        assert.strictEqual doc.foo, 20
        done()

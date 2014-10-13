assert = require 'power-assert'
async = require 'async'
{Model} = require 'mongoose'
_ = require 'underscore'

{User} = require('apps').models
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'
{generateHashedPassword} = require 'lib/crypto'


describe 'User Model', ->

  before (done) ->
    resetDatabase done

  it 'Model definition', ->
    assert(User.prototype instanceof Model)
    assert(User.queryOneById typeof 'function')


  describe 'Save Processing', ->

    afterEach (done) -> User.remove done

    it 'Create a document', (done) ->
      monky.build 'User', (e, user) ->
        assert user.email.length > 0
        assert.strictEqual user.salt.length, User.SALT_LENGTH
        assert user.verifyPassword valueSets.user.rawPassword
        user.save (e) ->
          return done e if e
          User.find (e, users) ->
            assert.strictEqual users.length, 1
            user = users[0]
            # salt が変わってないことを確認
            assert user.verifyPassword valueSets.user.rawPassword
            # 共通 plugin で設定されるフィールド群を代表して確認する
            assert user.created_at instanceof Date
            assert user.updated_at instanceof Date
            done()


  describe 'Fields', ->

    _assertExpectedFieldError = (e, fieldName) ->
      assert e.name is 'ValidationError'
      assert _.size(e.errors) is 1
      assert fieldName of e.errors

    it 'emailが必須ではない', (done) ->
      monky.build 'User', (e, user) ->
        user.email = null
        user.save done

    it 'emailが未定義を除外したunique制約である', (done) ->
      # unique & sparse 設定を代表で確認するということでもある
      User.remove (e) ->
        # 違うメルアド、または未定義なら重複登録可能である
        dataExtensions = [
          {email:'foo@example.com'}
          {email:'bar@example.com'}
          {email:undefined}
          {email:undefined}
        ]
        async.eachSeries dataExtensions, (extData, nextLoop) ->
          monky.build 'User', (e, user) ->
            _.extend user, extData
            user.save (e) ->
              return done e if e
              nextLoop()
        , (e) ->
          return done e if e
          # 重複したメルアドは保存できない
          monky.build 'User', (e, user) ->
            user.email = 'foo@example.com'
            user.save (e) ->
              assert e.name is 'MongoError'
              User.find().count (e, count) ->
                return done e if e
                assert count is 4
                done()

    it 'passwordが必須である', (done) ->
      monky.build 'User', (e, user) ->
        user.password = undefined
        user.save (e) ->
          _assertExpectedFieldError e, 'password'
          done()


  describe 'Queries', ->

    before (done) ->
      User.remove ->
        # ユーザーを数人用意
        async.eachSeries [
          'foo@example.com'
          'bar@example.com'
          'baz@example.com'
        ], (email, nextLoop) ->
          monky.build 'User', (e, user) ->
            user.email = email
            user.save nextLoop
        , done

    it 'queryActiveUsers/queryActiveUserByEmail', (done) ->
      User.queryActiveUsers().exec (e, docs) ->
        assert.strictEqual docs.length, 3
        User.queryActiveUserByEmail('foo@example.com').exec (e, doc) ->
          assert doc instanceof User
          User.queryActiveUserByEmail('x-foo@example.com').exec (e, doc) ->
            assert.strictEqual e, null
            assert.strictEqual doc, null
            done()


  describe 'Properties', ->

    it 'verifyPassword', ->
      user = new User
      user.salt = 'foo_salt'
      user.password = generateHashedPassword 'pasuwado', user.salt
      assert user.verifyPassword 'pasuwado'
      assert user.verifyPassword('pasuwadox') is false

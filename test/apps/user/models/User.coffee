assert = require 'power-assert'
async = require 'async'
{Model} = require 'mongoose'
_ = require 'underscore'

{User} = require 'apps/user/models'
{resetDatabase} = require 'helpers/database'
{generateHashedPassword} = require 'lib/util/crypto'


describe 'User Model', ->

  before (done) ->
    @validData =
      email: 'test@example.com'
      rawPassword: 'test1234'

    @createValidUser = (data={}) ->
      user = _.extend new User, {
        email: @validData.email
      }, data
      user.setPassword data.rawPassword ? @validData.rawPassword
      user

    resetDatabase done

  it 'Model definition', ->
    assert(User.prototype instanceof Model)
    assert(User.queryOneById typeof 'function')


  describe 'Save Processing', ->

    afterEach (done) -> User.remove done

    it 'Create a document', (done) ->
      self = @

      user = @createValidUser()
      assert user.email is @validData.email
      assert typeof user.salt is 'string'
      assert user.salt.length is User.SALT_LENGTH
      assert user.verifyPassword @validData.rawPassword

      user.save (e) ->
        return done e if e
        User.find (e, users) ->
          return done e if e
          assert users.length is 1
          user = users[0]
          assert user.verifyPassword self.validData.rawPassword
          # 共通 plugin で設定されるフィールド群を代表して確認する
          assert user.created_at instanceof Date
          assert user.updated_at instanceof Date
          done()


  describe 'Fields', ->

    _assertExpectedFieldError = (e, fieldName) ->
      assert e.name is 'ValidationError'
      assert _.size(e.errors) is 1
      assert fieldName of e.errors

    it 'email', (done) ->
      user = @createValidUser {email:null}
      user.save (e) ->
        return done e if e
        done()

    it 'emailが未定義を除外したunique制約である', (done) ->
      # unique, sparse 設定を代表で確認する
      self = @
      User.remove (e) ->
        return done e if e
        # 違うメルアドなら保存できること、email が存在しないなら重複できることを確認
        data = _.extend {}, self.validData
        delete data.email
        dataExtensions = [
          {email:'foo@example.com'}
          {email:'bar@example.com'}
          {email:undefined}
          {email:undefined}
        ]
        async.eachSeries dataExtensions, (extData, nextLoop) ->
          user = self.createValidUser extData
          user.save (e) ->
            return done e if e
            nextLoop()
        , (e) ->
          return done e if e
          # 重複したメルアドは保存できない
          user = self.createValidUser {email:'bar@example.com'}
          user.save (e) ->
            assert e.name is 'MongoError'
            User.find().count (e, count) ->
              return done e if e
              assert count is 4
              done()

    it 'password', (done) ->
      user = @createValidUser {email:null}
      user.password = undefined
      user.save (e) ->
        _assertExpectedFieldError e, 'password'
        done()


  describe 'Queries', ->

    before (done) ->
      self = @
      # 3 ユーザを用意
      User.remove (e) ->
        return done e if e
        async.eachSeries [
          'foo@example.com'
          'bar@example.com'
          'baz@example.com'
        ], (email, next) ->
          self.createValidUser(email:email).save next
        , (e) ->
          return done e if e
          done()

    it 'queryActiveUserByEmail', (done) ->
      User.queryActiveUserByEmail('foo@example.com').find (e, docs) ->
        return done e if e
        assert docs.length is 1
        assert docs[0].email is 'foo@example.com'
        User.queryActiveUserByEmail('foox@example.com').find (e, docs) ->
          return done e if e
          assert docs.length is 0
          done()


  describe 'Properties', ->

    it 'verifyPassword', ->
      user = new User
      user.salt = 'foo_salt'
      user.password = generateHashedPassword 'pasuwado', user.salt
      assert user.verifyPassword 'pasuwado'
      assert user.verifyPassword('pasuwadox') is false

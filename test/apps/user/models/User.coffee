assert = require 'assert'
async = require 'async'
{Model} = require 'mongoose'
_ = require 'underscore'

{User} = require 'apps/user/models'
{resetDatabase} = require 'helpers/test'
{generateHashedPassword} = require 'lib/util/crypto'


describe 'User Model', ->

  before (done) ->
    @validData =
      email: 'test@example.com'
      password: 'my_hashed_password'
      salt: 'my_salt'

    resetDatabase done

  it 'Model definition', ->
    assert(User.prototype instanceof Model)


  describe 'Save Processing', ->

    afterEach (done) -> User.remove done

    it 'Create a document', (done) ->
      user = new User
      _.extend user, @validData
      user.save (e) =>
        throw e if e
        User.find (e, docs) =>
          throw e if e
          assert docs.length is 1
          doc = docs[0]
          assert doc.password is @validData.password
          assert doc.salt is @validData.salt
          done()


  describe 'Fields', ->

    _assertExpectedFieldError = (e, fieldName) ->
      assert e.name is 'ValidationError'
      assert _.size(e.errors) is 1
      assert fieldName of e.errors

    it 'email', (done) ->
      user = new User
      _.extend user, @validData, { email:null }
      user.save (e) ->
        throw e if e  # Error is not occured
        done()

    it 'emailがnullを除外したunique制約である', (done) ->
      self = @
      # unique, sparse 設定を代表で確認する
      User.remove (e) ->
        throw e if e
        # 違うメルアドなら保存できること、email が存在しないなら重複できることを確認
        data = _.extend {}, self.validData
        delete data.email
        dataExtensions = [
          {email:'foo@example.com'}
          {email:'bar@example.com'}
          {}
          {}
        ]
        async.eachSeries dataExtensions, (extData, nextLoop) ->
          user = _.extend new User, data, extData
          user.save (e) ->
            throw e if e
            nextLoop()
        , (e) ->
          throw e if e
          # 重複したメルアドは保存できない
          user = _.extend new User, data, { email:'bar@example.com' }
          user.save (e) ->
            assert e.name is 'MongoError'
            User.find().count (e, count) ->
              throw e if e
              assert count is 4
              done()

    it 'password', (done) ->
      user = new User
      _.extend user, @validData, { password:null }
      user.save (e) ->
        _assertExpectedFieldError e, 'password'
        done()

    it 'salt', (done) ->
      user = new User
      _.extend user, @validData, { salt:null }
      user.save (e) ->
        _assertExpectedFieldError e, 'salt'
        done()


  describe 'Queries', ->

    before (done) ->
      self = @
      # 3 ユーザを用意
      User.remove (e) ->
        throw e if e
        async.eachSeries [
          'foo@example.com'
          'bar@example.com'
          'baz@example.com'
        ], (email, next) ->
          user = new User
          _.extend user, self.validData, { email:email, salt:email + '_salt' }
          user.save next
        , (e) ->
          throw e if e
          done()

    it 'queryActiveUserByEmail', (done) ->
      User.queryActiveUserByEmail('foo@example.com').find (e, docs) ->
        throw e if e
        assert docs.length is 1
        assert docs[0].email is 'foo@example.com'
        User.queryActiveUserByEmail('foox@example.com').find (e, docs) ->
          throw e if e
          assert docs.length is 0
          done()


  describe 'Properties', ->

    it 'verifyPassword', ->
      user = new User
      user.salt = 'foo_salt'
      user.password = generateHashedPassword 'pasuwado', user.salt
      assert user.verifyPassword 'pasuwado'
      assert user.verifyPassword('pasuwadox') is false

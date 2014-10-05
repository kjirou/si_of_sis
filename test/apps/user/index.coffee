assert = require 'power-assert'
_ = require 'underscore'

logics = require 'apps/user/logics'
{User} = require 'apps/user/models'
{resetDatabase} = require 'helpers/database'


describe 'user App', ->

  before (done) ->
    resetDatabase done


  describe 'Logics', ->

    before ->
      @defaultValues =
        email: 'foo@example.com'
        password: 'abcd1234'
      @prepareUser = (callback) =>
        logics.updateUser null, @defaultValues, (e, user) ->
          return callback e if e
          User.findOneById user._id, (e, user) ->
            return callback e if e
            callback user

    beforeEach (done) ->
      User.remove done

    it 'updateUserでユーザーを新規作成できる', (done) ->
      values =
        email: 'foo@example.com'
        password: 'abcd1234'
      logics.updateUser null, values, (e, result) ->
        return done e if e
        assert result instanceof User
        user = result
        User.findOneById user._id, (e, user) ->
          return done e if e
          assert user instanceof User
          done()

    it 'updateUserでバリデーション失敗時にエラーを返せる', (done) ->
      values =
        email: 'fooexamplecom'
        password: ''
      logics.updateUser null, values, (e, result) ->
        return done e if e
        assert(result instanceof User is false)
        assert result.isValid is false
        assert _.size(result.errors) is 2
        done()

    it 'updateUserでユーザーを更新できる', (done) ->
      @prepareUser (user) ->
        values =
          email: 'bar@example.com'
          password: 'bcde2345'
        logics.updateUser user, values, (e, result) ->
          return done e if e
          User.findOneById result._id, (e, user) ->
            return done e if e
            assert user.email is values.email
            assert user.verifyPassword values.password
            done()

assert = require 'power-assert'
_ = require 'underscore'

{Company, User} = require('apps').models
logics = require 'apps/user/logics'
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
        logics.postUser null, @defaultValues, (e, user) ->
          return callback e if e
          User.findOneById user._id, (e, user) ->
            return callback e if e
            callback user

    beforeEach (done) -> Company.remove -> User.remove done

    it 'postUserでユーザーを新規作成できる', (done) ->
      values =
        email: 'foo@example.com'
        password: 'abcd1234'
      logics.postUser null, values, (e, result) ->
        return done e if e
        assert result instanceof User
        user = result
        User.findOneById user._id, (e, user) ->
          return done e if e
          assert user instanceof User
          Company.findOne (e, company) ->
            return done e if e
            assert company instanceof Company
            done()

    it 'postUserでバリデーション失敗時にエラーを返せる', (done) ->
      values =
        email: 'fooexamplecom'
        password: ''
      logics.postUser null, values, (e, result) ->
        return done e if e
        assert(result instanceof User is false)
        assert result.isValid is false
        assert _.size(result.errors) is 2
        done()

    it 'postUserで既に存在するemailで新規作成できない', (done) ->
      @prepareUser (user) ->
        values =
          email: user.email
          password: 'abcd1234'
        logics.postUser null, values, (e, result) ->
          return done e if e
          assert result.isValid is false
          done()

    it 'postUserでユーザーを更新できる', (done) ->
      @prepareUser (user) ->
        values =
          email: user.email  # 更新時は重複判定されないことも確認
          password: 'bcde2345'
        logics.postUser user, values, (e, result) ->
          return done e if e
          User.findOneById result._id, (e, user) ->
            return done e if e
            assert user.email is values.email
            assert user.verifyPassword values.password
            done()

    it 'postUserでパスワードを空で更新できる', (done) ->
      @prepareUser (user) ->
        beforePassword = user.password
        values =
          email: 'bar@example.com'
          password: ''
        logics.postUser user, values, (e, result) ->
          return done e if e
          User.findOneById result._id, (e, user) ->
            return done e if e
            assert user.email is 'bar@example.com'
            assert beforePassword is user.password
            done()

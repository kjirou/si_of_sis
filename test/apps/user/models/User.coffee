_ = require 'underscore'
assert = require 'assert'
{Model} = require 'mongoose'

{User} = require 'apps/user/models'
{purgeDatabase} = require 'lib/util/test'


describe 'User Model', ->

  before (done) ->

    @validData =
      email: 'test@example.com'
      password: 'my_hashed_password'
      salt: 'my_salt'

    purgeDatabase done

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
        _assertExpectedFieldError e, 'email'
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

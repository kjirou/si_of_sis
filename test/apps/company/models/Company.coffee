assert = require 'power-assert'
{Model} = require 'mongoose'

{Company, User} = require('apps').models
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'


describe 'Company Model', ->

  before (done) ->
    @removeData = (callback) ->
      Company.remove -> User.remove callback
    resetDatabase done

  it 'Model definition', ->
    assert(Company.prototype instanceof Model)


  describe 'Save Processing', ->

    beforeEach (done) -> @removeData done

    it 'Create a document', (done) ->
      monky.build 'Company', (e, company) ->
        assert company.user instanceof User
        assert.strictEqual company.name, 'Default Company'
        assert.strictEqual company.cash, 0
        company.save (e) ->
          return done e if e
          Company.find (e, companies) ->
            assert.strictEqual companies.length, 1
            done()


  describe 'Fields', ->

    beforeEach (done) -> @removeData done

    it 'user', (done) ->
      monky.build 'Company', (e, company) ->
        # 必須か
        company.user = undefined
        company.save (e) ->
          assert e and e.name is 'ValidationError'
          # 一意か
          monky.create 'Company', (e, company) ->
            monky.create 'Company', { user: company.user._id }, (e, company) ->
              assert e and e.name is 'MongoError'
              done()

    it 'name', (done) ->
      monky.build 'Company', (e, company) ->
        company.name = undefined
        company.save (e) ->
          assert e and e.name is 'ValidationError'
          done()

    it 'cash', (done) ->
      monky.build 'Company', (e, company) ->
        # 必須か
        company.cash = undefined
        company.save (e) ->
          assert e and e.name is 'ValidationError'
          # 整数か
          company.cash = 0.1
          company.save (e) ->
            assert e and e.name is 'ValidationError'
            # 正の数か
            company.cash = -1
            company.save (e) ->
              assert e and e.name is 'ValidationError'
              done()

async = require 'async'
{Model} = require 'mongoose'
assert = require 'power-assert'

{Company, User} = require('apps').models
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'
{defineDocAssertions, removeCompanyCompletely} = require 'helpers/test'


describe 'Company Model', ->

  before (done) -> resetDatabase done

  it 'Model definition', ->
    assert(Company.prototype instanceof Model)


  describe 'Save Processing', ->

    beforeEach (done) -> removeCompanyCompletely done

    it 'Create a document', (done) ->
      monky.build 'Company', (e, company) ->
        assert company.user instanceof User
        assert company.name.length > 0
        assert.strictEqual company.cash, 0
        company.save (e) ->
          return done e if e
          Company.find (e, companies) ->
            assert.strictEqual companies.length, 1
            done()


  describe 'Fields', ->

    beforeEach (done) ->
      monky.build 'Company', (e, @doc) =>
        defineDocAssertions @doc
        removeCompanyCompletely done

    it 'user', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'user', '', next
        (next) => @doc.assertValidFieldValidation 'user', null, next
        # 一意か
        (next) ->
          monky.create 'Company', (e, company) ->
            return done e if e
            monky.create 'Company', { user: company.user._id }, (e, company) ->
              assert e and e.name is 'MongoError'
              next()
      ], done

    it 'name', (done) ->
      async.series [
        (next) => @doc.assertValidFieldValidation 'name', '', next
      ], done

    it 'cash', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'cash', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'cash', undefined, next
        (next) => @doc.assertValidFieldValidation 'cash', -1, next
        (next) => @doc.assertValidFieldValidation 'cash', 1.1, next
      ], done

    it 'max_stamina', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'max_stamina', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'max_stamina', undefined, next
        (next) => @doc.assertValidFieldValidation 'max_stamina', 0, next
        (next) => @doc.assertValidFieldValidation 'max_stamina', 1.1, next
      ], done

    it 'stamina', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'stamina', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'stamina', undefined, next
        (next) => @doc.assertValidFieldValidation 'stamina', -1, next
        (next) => @doc.assertValidFieldValidation 'stamina', 1.1, next
      ], done


  describe 'Methods', ->

    beforeEach (done) ->
      monky.build 'Company', (e, @doc) => done()

    it 'cash is applied consumable-plugin', ->
      @doc.cash = 100
      @doc.supplyCash Company.MAX_CASH
      assert @doc.cash is Company.MAX_CASH

    it 'stamina is applied consumable-plugin', ->
      @doc.max_stamina = 100
      @doc.stamina = 0
      @doc.supplyStamina 10
      assert @doc.stamina is 10
      @doc.supplyStamina 999
      assert @doc.stamina is 100

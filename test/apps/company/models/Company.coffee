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

    it 'max_business_power', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'max_business_power', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'max_business_power', undefined, next
        (next) => @doc.assertValidFieldValidation 'max_business_power', 0, next
        (next) => @doc.assertValidFieldValidation 'max_business_power', 1.1, next
      ], done

    it 'business_power', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'business_power', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'business_power', undefined, next
        (next) => @doc.assertValidFieldValidation 'business_power', -1, next
        (next) => @doc.assertValidFieldValidation 'business_power', 1.1, next
      ], done

assert = require 'power-assert'
async = require 'async'
{Model} = require 'mongoose'
_ = require 'lodash'

{Business} = require('apps').models
{resetDatabase} = require 'helpers/database'
{defineDocAssertions} = require 'helpers/test'
{monky, valueSets} = require 'helpers/monky'


describe 'Business Model', ->

  before (done) -> resetDatabase done

  it 'Model definition', ->
    assert Business.prototype instanceof Model


  describe 'Save Processing', ->

    afterEach (done) -> Business.remove done

    it 'Create a document', (done) ->
      monky.build 'Business', (e, business) ->
        business.save (e) ->
          return done e if e
          Business.find (e, businesses) ->
            assert.strictEqual businesses.length, 1
            done()


  describe 'Fields', ->

    beforeEach (done) ->
      monky.build 'Business', (e, @doc) =>
        defineDocAssertions @doc
        Business.remove done

    it 'name', (done) ->
      async.series [
        (next) => @doc.assertValidFieldValidation 'name', '', next
      ], done

    it 'business_cost', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'business_cost', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'business_cost', undefined, next
        (next) => @doc.assertValidFieldValidation 'business_cost', -1, next
        (next) => @doc.assertValidFieldValidation 'business_cost', 1.1, next
      ], done

    it 'development_cost', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'development_cost', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'development_cost', undefined, next
        (next) => @doc.assertValidFieldValidation 'development_cost', 0, next
        (next) => @doc.assertValidFieldValidation 'development_cost', 1.1, next
      ], done

    it 'asking_price', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'asking_price', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'asking_price', undefined, next
        (next) => @doc.assertValidFieldValidation 'asking_price', 0, next
        (next) => @doc.assertValidFieldValidation 'asking_price', 1.1, next
      ], done

    it 'raw_closing_week', (done) ->
      async.series [
        (next) => @doc.assertValidFieldValidation 'raw_closing_week', '0000000101a', next
        (next) => @doc.assertValidFieldValidation 'raw_closing_week', '', next
      ], done

    it 'development_weeks', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'development_weeks', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'development_weeks', undefined, next
        (next) => @doc.assertValidFieldValidation 'development_weeks', -1, next
        (next) => @doc.assertValidFieldValidation 'development_weeks', 1.1, next
      ], done

    #it 'delivery_week', ->

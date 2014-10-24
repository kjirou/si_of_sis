assert = require 'power-assert'
async = require 'async'
{Model} = require 'mongoose'
_ = require 'underscore'

{Business} = require('apps').models
{resetDatabase} = require 'helpers/database'
{defineDocAssertions} = require 'helpers/test'
{monky, valueSets} = require 'helpers/monky'


describe 'Business Model', ->

  before (done) ->
    resetDatabase done

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
      monky.build 'Business', (e, @business) =>
        defineDocAssertions @business
        done()

    it 'name', (done) ->
      async.series [
        (next) => @business.assertValidFieldValidation 'name', '', next
      ], done

    it 'base_value', (done) ->
      async.series [
        (next) => @business.assertValidFieldType 'base_value', 'not_numeric', next
        (next) => @business.assertValidFieldValidation 'base_value', undefined, next
      ], done

    it 'added_value', (done) ->
      async.series [
        (next) => @business.assertValidFieldType 'added_value', 'not_numeric', next
        (next) => @business.assertValidFieldValidation 'added_value', undefined, next
      ], done

    it 'development_cost', (done) ->
      async.series [
        (next) => @business.assertValidFieldType 'development_cost', 'not_numeric', next
        (next) => @business.assertValidFieldValidation 'development_cost', undefined, next
        (next) => @business.assertValidFieldValidation 'development_cost', 0, next
        (next) => @business.assertValidFieldValidation 'development_cost', 1.1, next
      ], done

    it 'progress', (done) ->
      async.series [
        (next) => @business.assertValidFieldType 'progress', 'not_numeric', next
        (next) => @business.assertValidFieldValidation 'progress', undefined, next
        (next) => @business.assertValidFieldValidation 'progress', -0.1, next
      ], done

    it 'asking_price', (done) ->
      async.series [
        (next) => @business.assertValidFieldType 'asking_price', 'not_numeric', next
        (next) => @business.assertValidFieldValidation 'asking_price', undefined, next
        (next) => @business.assertValidFieldValidation 'asking_price', 0, next
        (next) => @business.assertValidFieldValidation 'asking_price', 1.1, next
      ], done

    it 'progress_rate', ->
      @business.development_cost = 100
      @business.progress = 75
      assert.strictEqual @business.progress_rate, 0.75
      @business.progress = 110
      assert.strictEqual @business.progress_rate, 1.0

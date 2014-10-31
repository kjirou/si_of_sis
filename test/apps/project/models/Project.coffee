async = require 'async'
_ = require 'lodash'
mongoose = require 'mongoose'
{Model} = mongoose
{ObjectId} = mongoose.Types
assert = require 'power-assert'

{Project} = require('apps').models
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'
{defineDocAssertions, removeProjectCompletely} = require 'helpers/test'
{GameDate} = require 'lib/game-date'


describe 'Project Model', ->

  before (done) -> resetDatabase done

  it 'Model definition', ->
    assert Project.prototype instanceof Model


  describe 'Save Processing', ->

    afterEach (done) -> removeProjectCompletely done

    it 'Create a document', (done) ->
      monky.build 'Project', (e, project) ->
        return done e if e
        project.save (e) ->
          return done e if e
          Project.find (e, projects) ->
            assert.strictEqual projects.length, 1
            done()


  describe 'Fields', ->

    beforeEach (done) ->
      monky.build 'Project', (e, @doc) =>
        return done e if e
        defineDocAssertions @doc
        removeProjectCompletely done

    it 'business', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'business', '', next
        (next) => @doc.assertValidFieldValidation 'business', null, next
      ], done

    it 'raw_ordered_week', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'raw_ordered_week', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'raw_ordered_week', -1, next
        (next) => @doc.assertValidFieldValidation 'raw_ordered_week', 1.1, next
      ], done

    it 'raw_delivered_week', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'raw_delivered_week', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'raw_delivered_week', -1, next
        (next) => @doc.assertValidFieldValidation 'raw_delivered_week', 1.1, next
      ], done

    it 'progress', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'progress', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'progress', null, next
        (next) => @doc.assertValidFieldValidation 'progress', -0.1, next
      ], done

    it 'added_value', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'added_value', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'added_value', null, next
      ], done

    it 'price', (done) ->
      async.series [
        (next) => @doc.assertValidFieldType 'price', 'not_numeric', next
        (next) => @doc.assertValidFieldValidation 'price', null, next
        (next) => @doc.assertValidFieldValidation 'price', 0, next
        (next) => @doc.assertValidFieldValidation 'price', 1.1, next
      ], done

    it 'business_id', (done) ->
      # monky.build の場合は populated が正常に動かなかった
      # 他のモデルは assert xxx_id で存在判定だけすればいいや
      monky.create 'Project', (e, project) ->
        return done e if e
        Project.findById project._id, (e, project) ->
          return done e if e
          assert project.business_id instanceof ObjectId
          done()

    it 'ordered_week', ->
      @doc.raw_ordered_week = 1
      assert @doc.ordered_week instanceof GameDate
      assert.deepEqual @doc.ordered_week.toArray(), [0, 0, 1]

    it 'delivered_week', ->
      @doc.raw_delivered_week = 1
      assert @doc.delivered_week instanceof GameDate
      assert.deepEqual @doc.delivered_week.toArray(), [0, 0, 1]

    it 'progress_rate', (done) ->
      monky.create 'Business', (e, business) ->
        return done e if e
        monky.create 'Project', {business: business._id}, (e, project) ->
          return done e if e
          assert.throws ->
            project.progress_rate
          , /business/
          project.populate 'business', (e, project) ->
            return done e if e
            project.progress_rate
            project.progress = 75
            project.business.development_cost = 100
            assert project.progress_rate is 0.75
            project.progress = 110
            assert project.progress_rate is 1.0
            done()

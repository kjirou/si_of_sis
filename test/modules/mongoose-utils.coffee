mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
assert = require 'power-assert'

{Company, User} = require('apps').models
{resetDatabase} = require 'helpers/database'
testHelper = require 'helpers/test'
{monky, valueSets} = require 'helpers/monky'
{isObjectId, toObjectIdCondition, purgeDatabase,
  assertPopulated, executeRemovingToEachModels} = require 'modules/mongoose-utils'


describe 'mongoose-utils Module', ->

  beforeEach (done) -> testHelper.removeCompanyCompletely done

  it 'isObjectId', ->
    assert isObjectId '0123456789abcdef01234567'
    assert isObjectId '0123456789abcdef01234567'
    assert isObjectId('0123456789abcdef012345670') is false
    assert isObjectId(null) is false
    assert isObjectId(undefined) is false
    assert isObjectId(ObjectId('0123456789abcdef01234567'))

  it 'toObjectIdCondition', ->
    assert toObjectIdCondition('0123456789abcdef01234567') instanceof ObjectId
    assert toObjectIdCondition('0123456789abcdef01234567') instanceof ObjectId
    assert toObjectIdCondition('0123456789abcdef012345670') is null

  it 'assertPopulated', (done) ->
    monky.create 'Company', (e, company) ->
      Company.findById company._id, (e, company) ->
        assert.throws ->
          assertPopulated company, 'user'
        , /user/
        company.populate 'user', (e, company) ->
          assertPopulated company, 'user'
          done()

  it 'purgeDatabase', (done) ->
    # モデルを空にして 0 件か
    testHelper.createTestModel new Schema, (e, Test) ->
      return done e if e
      Test.remove ->
        Test.find().count (e, count) ->
          assert count is 0
          # 1 件保存して 1 件か
          (new Test).save (e) ->
            Test.find().count (e, count) ->
              assert count is 1
              # purgeDatabase して 0 件か
              purgeDatabase (e) ->
                Test.find().count (e, count) ->
                  assert count is 0
                  done()

  it 'executeRemovingToEachModels', (done) ->
    resetDatabase ->
      monky.create 'Company', (e, company) ->
        Company.count (e, count) ->
          assert.strictEqual count, 1
          User.count (e, count) ->
            assert.strictEqual count, 1
            executeRemovingToEachModels [Company, User], (e) ->
              Company.count (e, count) ->
                assert.strictEqual count, 0
                User.count (e, count) ->
                  assert.strictEqual count, 0
                  done()

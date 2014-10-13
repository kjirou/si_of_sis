mongoose = require 'mongoose'
{Schema} = mongoose
{ObjectId} = mongoose.Types
assert = require 'power-assert'

{Company, User} = require('apps').models
{resetDatabase} = require 'helpers/database'
testHelper = require 'helpers/test'
{monky, valueSets} = require 'helpers/monky'
mongooseUtils = require 'modules/mongoose-utils'


describe 'mongoose Utils', ->

  it 'isObjectIdString', ->
    {isObjectIdString} = mongooseUtils
    assert mongooseUtils.isObjectIdString '0123456789abcdef01234567'
    assert isObjectIdString '0123456789abcdef01234567'
    assert mongooseUtils.isObjectIdString('0123456789abcdef012345670') is false
    assert mongooseUtils.isObjectIdString('0123456789abcdeg01234567') is false
    assert mongooseUtils.isObjectIdString(null) is false
    assert mongooseUtils.isObjectIdString(undefined) is false
    assert mongooseUtils.isObjectIdString(ObjectId('0123456789abcdef01234567')) is false

  it 'isObjectId', ->
    {isObjectId} = mongooseUtils
    assert mongooseUtils.isObjectId '0123456789abcdef01234567'
    assert isObjectId '0123456789abcdef01234567'
    assert mongooseUtils.isObjectId('0123456789abcdef012345670') is false
    assert mongooseUtils.isObjectId(null) is false
    assert mongooseUtils.isObjectId(undefined) is false
    assert mongooseUtils.isObjectId(ObjectId('0123456789abcdef01234567'))

  it 'toObjectIdCondition', ->
    {toObjectIdCondition} = mongooseUtils
    assert mongooseUtils.toObjectIdCondition('0123456789abcdef01234567') instanceof ObjectId
    assert toObjectIdCondition('0123456789abcdef01234567') instanceof ObjectId
    assert mongooseUtils.toObjectIdCondition('0123456789abcdef012345670') is null

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
              mongooseUtils.purgeDatabase (e) ->
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
            mongooseUtils.executeRemovingToEachModels [Company, User], (e) ->
              Company.count (e, count) ->
                assert.strictEqual count, 0
                User.count (e, count) ->
                  assert.strictEqual count, 0
                  done()

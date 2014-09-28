assert = require 'assert'
mongoose = require 'mongoose'
{Model, Schema} = mongoose

databaseHelper = require 'helpers/database'
testHelper = require 'helpers/test'


describe 'test Helper', ->

  before (done) ->
    databaseHelper.resetDatabase done

  it 'createTestModel', (done) ->
    testHelper.createTestModel new Schema, (e, TestModel) ->
      assert /^Test+\d/.test TestModel.modelName
      assert TestModel.prototype instanceof Model

      # 同じ名前ではない
      testHelper.createTestModel new Schema, (e, TestModel2) ->
        assert TestModel.modelName isnt TestModel2.modelName

        # インデックスが付与されている
        testHelper.createTestModel new Schema({
          x:
            type: String
            index:
              unique: true
        }), (e, TestModel3) ->
          TestModel3.collection.getIndexes (e, indexes) ->
            assert 'x_1' of indexes
            done()

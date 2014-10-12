assert = require 'power-assert'

{Company, User} = require('apps').models
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'
mongooseUtil = require 'lib/util/mongoose'


describe 'mongoose Util', ->

  before (done) ->
    resetDatabase done

  it 'executeRemovingToEachModels', (done) ->
    Company.remove ->
      User.remove ->
        monky.create 'Company', (e, company) ->
          Company.count (e, count) ->
            assert.strictEqual count, 1
            User.count (e, count) ->
              assert.strictEqual count, 1
              mongooseUtil.executeRemovingToEachModels [Company, User], (e) ->
                Company.count (e, count) ->
                  assert.strictEqual count, 0
                  User.count (e, count) ->
                    assert.strictEqual count, 0
                    done()

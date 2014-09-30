assert = require 'assert'
{ObjectId} = require('mongoose').Types

{Sandbox} = require 'apps/core/models'
mongodbUtil = require 'lib/util/mongodb'


describe 'mongodb Util', ->

  it 'isObjectIdString', ->
    assert mongodbUtil.isObjectIdString '0123456789abcdef01234567'
    assert mongodbUtil.isObjectIdString('0123456789abcdef012345670') is false
    assert mongodbUtil.isObjectIdString('0123456789abcdeg01234567') is false
    assert mongodbUtil.isObjectIdString(null) is false
    assert mongodbUtil.isObjectIdString(undefined) is false
    assert mongodbUtil.isObjectIdString(ObjectId('0123456789abcdef01234567')) is false

  it 'isObjectId', ->
    assert mongodbUtil.isObjectId '0123456789abcdef01234567'
    assert mongodbUtil.isObjectId('0123456789abcdef012345670') is false
    assert mongodbUtil.isObjectId(null) is false
    assert mongodbUtil.isObjectId(undefined) is false
    assert mongodbUtil.isObjectId(ObjectId('0123456789abcdef01234567'))

  it 'purgeDatabase', (done) ->
    # モデルを空にして 0 件か
    Sandbox.remove ->
      Sandbox.find().count (e, count) ->
        assert count is 0
        # 1 件保存して 1 件か
        (new Sandbox).save (e) ->
          Sandbox.find().count (e, count) ->
            assert count is 1
            # purgeDatabase して 0 件か
            mongodbUtil.purgeDatabase (e) ->
              Sandbox.find().count (e, count) ->
                assert count is 0
                done()

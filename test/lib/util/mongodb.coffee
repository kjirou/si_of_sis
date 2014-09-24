assert = require 'assert'

mongodbUtil = require 'lib/util/mongodb'
{Sandbox} = require 'apps/core/models'


describe 'mongodb Util', ->

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

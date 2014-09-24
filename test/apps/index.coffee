assert = require 'assert'
sinon = require 'sinon'
_ = require 'underscore'

apps = require 'apps'


describe 'apps Module', ->

  before ->
    @mocks = []

  afterEach ->
    mock.restore() for mock in @mocks
    @mocks = []

  it 'Module definition', ->
    assert typeof apps is 'object'
    # 動的生成しているプロパティをある程度確認する
    assert _.size(apps.subApps) > 0
    assert _.size(apps.models) > 0

  it 'ensureModelIndexes', (done) ->
    # 実際にインデックスの有無を確認するのは手間なので
    # mongoose.Model.ensureIndexes が実行されたかでテストする
    spies = for modelName, model of apps.models
      sinon.spy model, 'ensureIndexes'
    apps.ensureModelIndexes (e) =>
      throw e if e
      assert spies.length > 0
      for spy in spies
        assert spy.callCount is 1
      @mocks = @mocks.concat spies
      done()

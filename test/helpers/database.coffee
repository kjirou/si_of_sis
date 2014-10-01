assert = require 'power-assert'
sinon = require 'sinon'

apps = require 'apps'
databaseHelper = require 'helpers/database'


describe 'database Helper', ->

  before ->
    @mocks = []

  afterEach ->
    mock.restore() for mock in @mocks
    @mocks = []

  it 'ensureModelIndexes', (done) ->
    # 実際にインデックスの有無を確認するのは手間なので
    # mongoose.Model.ensureIndexes が実行されたかでテストする
    spies = for modelName, model of apps.models
      sinon.spy model, 'ensureIndexes'
    databaseHelper.ensureModelIndexes (e) =>
      return done e if e
      assert spies.length > 0
      for spy in spies
        assert spy.callCount is 1
      @mocks = @mocks.concat spies
      done()

  it 'resetDatabase', (done) ->
    databaseHelper.resetDatabase (e) ->
      return done e if e
      done()

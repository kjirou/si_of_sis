assert = require 'assert'
sinon = require 'sinon'

coreUtil = require 'lib/util/core'


describe 'core Util', ->

  before ->
    @mocks = []

  afterEach ->
    for mock in @mocks
      mock.restore()

  it 'want', ->
    assert require('util') is coreUtil.want('util')
    assert coreUtil.want('notexistedmodule') is null

    # MODUlE_NOT_FOUND 以外のエラーは throw されることを確認する
    want = coreUtil.want
    error = new Error 'Not MODULE_NOT_FOUND Error'
    @mocks.push(sinon.stub coreUtil, 'want', -> throw error)
    assert.throws ->
      coreUtil.want()
    , (e) -> e is error

assert = require 'power-assert'
_ = require 'underscore'

apps = require 'apps'


describe 'apps Module', ->

  it 'Module definition', ->
    assert typeof apps is 'object'
    # 動的生成しているプロパティをある程度確認する
    assert _.size(apps.subApps) > 0
    assert _.size(apps.models) > 0

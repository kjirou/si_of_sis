assert = require 'power-assert'

textUtil = require 'lib/util/text'


describe 'text Util', ->

  it 'createRandomCompanyName', ->
    for i in [0..100]
      word = textUtil.createRandomCompanyName()
      assert /^[a-z]{10} /i.test word

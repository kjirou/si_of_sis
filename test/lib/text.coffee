assert = require 'power-assert'

textLib = require 'lib/text'


describe 'text Lib', ->

  it 'createRandomCompanyName', ->
    for i in [0..100]
      word = textLib.createRandomCompanyName()
      assert /^[a-z]{10} /i.test word

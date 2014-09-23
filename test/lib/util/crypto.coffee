assert = require 'assert'

conf = require 'conf'
cryptoUtil = require 'lib/util/crypto'


describe 'crypto Util', ->

  before ->
    @originalHmacSecretKey = conf.auth.hmacSecretKey

  afterEach ->
    conf.auth.hmacSecretKey = @originalHmacSecretKey

  it 'generateHashedPassword', ->
    taro =
      hashedPassword: ''
      salt: 'taro_12345678901234567890'
    password = cryptoUtil.generateHashedPassword 'taro_desu', taro.salt

    assert typeof password is 'string'
    assert password.length > 0
    assert password is cryptoUtil.generateHashedPassword 'taro_desu', taro.salt
    assert password isnt cryptoUtil.generateHashedPassword 'xtaro_desu', taro.salt
    assert password isnt cryptoUtil.generateHashedPassword 'taro_desu', 'another_salt'
    conf.auth.hmacSecretKey += 'x'
    assert password isnt cryptoUtil.generateHashedPassword 'taro_desu', taro.salt

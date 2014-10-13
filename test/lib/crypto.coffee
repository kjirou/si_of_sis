assert = require 'power-assert'

conf = require 'conf'
cryptoLib = require 'lib/crypto'


describe 'crypto Lib', ->

  before ->
    @originalHmacSecretKey = conf.auth.hmacSecretKey

  afterEach ->
    conf.auth.hmacSecretKey = @originalHmacSecretKey

  it 'generateHashedPassword', ->
    taro =
      hashedPassword: ''
      salt: 'taro_12345678901234567890'
    password = cryptoLib.generateHashedPassword 'taro_desu', taro.salt

    assert typeof password is 'string'
    assert password.length > 0
    assert password is cryptoLib.generateHashedPassword 'taro_desu', taro.salt
    assert password isnt cryptoLib.generateHashedPassword 'xtaro_desu', taro.salt
    assert password isnt cryptoLib.generateHashedPassword 'taro_desu', 'another_salt'
    conf.auth.hmacSecretKey += 'x'
    assert password isnt cryptoLib.generateHashedPassword 'taro_desu', taro.salt

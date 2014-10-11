mongoose = require 'mongoose'
Monky = require 'monky'
_ = require 'underscore'

require 'apps'  # 全 Model 生成が必要なので呼んでいる
crypto = require 'lib/util/crypto'


monky = new Monky mongoose
valueSets =
  user:
    email: 'foo@example.com'
    rawPassword: 'test1234'


monky.factory 'User', _.extend {
  password: -> crypto.generateHashedPassword valueSets.user.rawPassword, @salt
}, _.pick(valueSets.user, 'email')


module.exports =
  monky: monky
  valueSets: valueSets

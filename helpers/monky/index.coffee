mongoose = require 'mongoose'
Monky = require 'monky'
_ = require 'underscore'

require 'apps'  # 全 Model 生成が必要なので呼んでいる
crypto = require 'lib/util/crypto'


monky = new Monky mongoose
valueSets = {}


#
# User
#
valueSets.user =
  email: 'test-#n@example.com'
  password: -> crypto.generateHashedPassword valueSets.user.rawPassword, @salt
  rawPassword: 'test1234'
monky.factory 'User', _.omit(valueSets.user, 'rawPassword')


#
# Company
#
valueSets.company = {}
monky.factory 'Company', {
  user: monky.ref 'User'
}


module.exports =
  monky: monky
  valueSets: valueSets

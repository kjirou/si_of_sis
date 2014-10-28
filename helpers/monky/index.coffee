_ = require 'lodash'
mongoose = require 'mongoose'
Monky = require 'monky'

require 'apps'  # 全 Model 生成が必要なので呼んでいる
crypto = require 'lib/crypto'


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


#
# Business
#
valueSets.business = {}
monky.factory 'Business', {}
monky.factory {name:'FakeBusiness', model:'Business'}, {
  name: ->
    _.sample(['C++', 'Java', 'JavaScript', 'Node.js', 'Perl', 'PHP', 'Python', 'Ruby']) + '開発案件'
  development_cost: -> _.random 1, 9999
  asking_price: -> _.random 1, 9999
}


#
# Project
#
valueSets.project =
  raw_ordered_week: '00000001011'
monky.factory 'Project', _.extend {
  business: monky.ref 'Business'
}, valueSets.project


module.exports =
  monky: monky
  valueSets: valueSets

_ = require 'lodash'
mongoose = require 'mongoose'
Monky = require 'monky'

require 'apps'  # 全 Model 生成が必要なので呼んでいる
crypto = require 'lib/crypto'
{GameDate} = require 'lib/game-date'


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
valueSets.business =
  raw_closing_week: '00000001011'
monky.factory 'Business', valueSets.business
monky.factory {name:'FakeBusiness', model:'Business'}, _.extend({}, valueSets.business, {
  name: ->
    _.sample(['C++', 'Java', 'JavaScript', 'Node.js', 'Perl', 'PHP', 'Python', 'Ruby']) + '開発案件'
  business_cost: -> _.random 1, 99
  development_cost: -> _.random 1, 9999
  asking_price: -> _.random 1, 9999
  raw_closing_week: -> (new GameDate).add(_.random(96), 'weeks').toString()
})


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

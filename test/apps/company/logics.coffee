assert = require 'power-assert'
_ = require 'underscore'

{Company} = require('apps').models
logics = require 'apps/company/logics'
{resetDatabase} = require 'helpers/database'
{monky, valueSets} = require 'helpers/monky'
{removeCompanyCompletely} = require 'helpers/test'


describe 'company Logics', ->

  before (done) -> resetDatabase done

  beforeEach (done) ->
    removeCompanyCompletely (e) =>
      return done e if e
      monky.create 'Company', (e, company) =>
        @company = company
        done()

  it 'postCompanyで会社情報を変更できる', (done) ->
    values =
      name: 'Foo Company'
    logics.postCompany @company, values, (e, result) ->
      return done e if e
      assert result instanceof Company
      Company.findOneById result._id, (e, company) ->
        return done e if e
        assert.strictEqual company.name, values.name
        done()

  it 'postCompanyでバリデーション失敗時にエラーを返せる', (done) ->
    values =
      name: ''
    logics.postCompany @company, values, (e, result) ->
      return done e if e
      assert(result instanceof Company is false)
      assert not result.isValid
      done()

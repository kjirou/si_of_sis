assert = require 'power-assert'
{Model} = require 'mongoose'

{Company} = require('apps').models
{resetDatabase} = require 'helpers/database'


describe 'Company Model', ->

  before (done) ->
    resetDatabase done

  it 'Model definition', ->
    assert(Company.prototype instanceof Model)

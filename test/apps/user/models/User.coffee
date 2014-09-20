assert = require 'assert'

{Model} = require 'mongoose'
{User} = require 'apps/user/models'


describe 'User Model', ->

  it 'Model definition', ->
    assert(User.prototype instanceof Model)

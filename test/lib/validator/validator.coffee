assert = require 'power-assert'

{validator} = require 'lib/validator'


describe 'validator Extensions', ->

  it 'isInvalid', ->
    assert typeof validator.isInvalid is 'function'
    assert validator.isInvalid() is false

  it 'isGreaterThan', ->
    assert typeof validator.isGreaterThan is 'function'
    assert validator.isGreaterThan '3', 2.9
    assert validator.isGreaterThan('3', 3) is false
    assert validator.isGreaterThan('3.1', 3)

  it 'isLessThan', ->
    assert typeof validator.isLessThan is 'function'
    assert validator.isLessThan '2.9', 3
    assert validator.isLessThan('3', 3) is false
    assert validator.isLessThan '3', 3.1

  it 'isRequired', ->
    assert typeof validator.isInvalid is 'function'
    assert validator.isRequired 'a'
    assert validator.isRequired('') is false

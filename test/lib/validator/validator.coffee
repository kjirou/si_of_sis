assert = require 'power-assert'

{validator} = require 'lib/validator'


describe 'validator Extensions', ->

  it 'isInvalid', ->
    assert typeof validator.isInvalid is 'function'
    assert validator.isInvalid() is false

  it 'isGreaterThan', ->
    assert validator.isGreaterThan '3', 2.9
    assert validator.isGreaterThan('3', 3) is false
    assert validator.isGreaterThan('3.1', 3)

  it 'isLessThan', ->
    assert validator.isLessThan '2.9', 3
    assert validator.isLessThan('3', 3) is false
    assert validator.isLessThan '3', 3.1

  it 'isRequired', ->
    assert validator.isRequired 'a'
    assert validator.isRequired('') is false

  it 'isPositiveInt', ->
    assert validator.isPositiveInt('0')
    assert validator.isPositiveInt('1')
    assert validator.isPositiveInt('1.1') is false
    assert validator.isPositiveInt('-1') is false
    assert validator.isPositiveInt('-0.1') is false
    assert validator.isPositiveInt('not_numeric') is false

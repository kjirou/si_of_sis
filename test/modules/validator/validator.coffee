assert = require 'power-assert'

{validator} = require 'modules/validator'


describe 'validator Extensions', ->

  it 'isEqualGreaterThan', ->
    assert validator.isEqualGreaterThan '3.1', 3
    assert validator.isEqualGreaterThan '3', 3
    assert validator.isEqualGreaterThan('3', 3.1) is false
    assert validator.isEqualGreaterThan 1.23456789, '1.23456789'
    assert validator.isEqualGreaterThan(1.23456788, '1.23456789') is false

  it 'isEqualLessThan', ->
    assert validator.isEqualLessThan '3', 3.1
    assert validator.isEqualLessThan '3', 3
    assert validator.isEqualLessThan('3.1', 3) is false
    assert validator.isEqualLessThan 1.23456789, '1.23456789'
    assert validator.isEqualLessThan(1.23456789, '1.23456788') is false

  it 'isGameDate', ->
    assert validator.isGameDate '00000001011'
    assert validator.isGameDate '99999999094'
    assert validator.isGameDate '99999999124'
    assert validator.isGameDate('00000001010') is false
    assert validator.isGameDate('00000001015') is false
    assert validator.isGameDate('00000001010') is false
    assert validator.isGameDate('00000001001') is false
    assert validator.isGameDate('00000001211') is false
    assert validator.isGameDate('00000000011') is false

  it 'isGreaterThan', ->
    assert validator.isGreaterThan '3', 2.9
    assert validator.isGreaterThan('3', 3) is false
    assert validator.isGreaterThan('3.1', 3)

  it 'isInvalid', ->
    assert typeof validator.isInvalid is 'function'
    assert validator.isInvalid() is false

  it 'isLessThan', ->
    assert validator.isLessThan '2.9', 3
    assert validator.isLessThan('3', 3) is false
    assert validator.isLessThan '3', 3.1

  it 'isPositiveInt', ->
    assert validator.isPositiveInt('0')
    assert validator.isPositiveInt('1')
    assert validator.isPositiveInt('1.1') is false
    assert validator.isPositiveInt('-1') is false
    assert validator.isPositiveInt('-0.1') is false
    assert validator.isPositiveInt('not_numeric') is false

  it 'isPositiveNumber', ->
    assert validator.isPositiveNumber('0')
    assert validator.isPositiveNumber('1')
    assert validator.isPositiveNumber('1.1') is false
    assert validator.isPositiveNumber('-1') is false
    assert validator.isPositiveNumber('-0.1') is false
    assert validator.isPositiveNumber('not_numeric') is false

  it 'isRequired', ->
    assert validator.isRequired 'a'
    assert validator.isRequired('') is false

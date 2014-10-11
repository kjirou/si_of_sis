validator = require 'validator'


validator.extend 'isPositiveInt', (str) ->
  return false unless @isInt(str)
  int = @toInt str
  not isNaN(int) and int >= 0

validator.extend 'isGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num > threshold

validator.extend 'isInvalid', -> false

validator.extend 'isLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num < threshold

validator.extend 'isRequired', (str) ->
  str.length > 0


module.exports = validator

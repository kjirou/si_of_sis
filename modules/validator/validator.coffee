validator = require 'validator'


validator.extend 'isEqualGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num >= threshold

validator.extend 'isEqualLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num <= threshold

# GameDate クラスと要同期、こちらは月・週が範囲外だとエラー
IS_GAME_DATE_REGEX = /^\d{7}[1-9](0[1-9]|1[0-2])[1-4]$/
validator.extend 'isGameDate', (str) ->
  IS_GAME_DATE_REGEX.test str

validator.extend 'isGreaterThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num > threshold

validator.extend 'isInvalid', -> false

validator.extend 'isLessThan', (str, threshold) ->
  num = parseFloat str
  not isNaN(num) and num < threshold

validator.extend 'isPositiveInt', (str) ->
  return false unless @isInt str
  int = @toInt str
  not isNaN(int) and int >= 0

validator.extend 'isPositiveNumber', (str) ->
  return false unless @isNumeric str
  num = Number str
  not isNaN(num) and num >= 0

validator.extend 'isRequired', (str) ->
  str.length > 0


module.exports = validator

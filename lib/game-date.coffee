#
# ゲーム日付モジュール
#

_ = require 'lodash'
_s = require 'underscore.string'


@GameDate = class GameDate

  MIN_YEAR = 1
  MAX_YEAR = 99999999
  MONTHS = [1..12]
  MIN_MONTH = _.first MONTHS
  MAX_MONTH = _.last MONTHS
  WEEKS = [1..4]
  MIN_WEEK = _.first WEEKS
  MAX_WEEK = _.last WEEKS
  # validator.isGameDate と要同期
  GAME_DATE_REGEX = /^(\d{8})(\d{2})(\d)$/

  # 月・週はそれぞれ最小値から最大値の範囲を超えても指定できる
  constructor: (args...) ->
    # 文字列から
    if args.length is 1 and _.isString args[0]
      [@_year, @_month, @_week] = @constructor.parseGameDateString args[0]
    # y, [m], [w]
    else
      [@_year, @_month, @_week] = args
      @_year ?= MIN_YEAR
      @_month ?= MIN_MONTH
      @_week ?= MIN_WEEK

    Object.defineProperty @, 'year', get: -> @_year
    Object.defineProperty @, 'month', get: -> @_month
    Object.defineProperty @, 'week', get: -> @_week

    @_adjustDate()

  @validateGameDateString: (str) ->
    GAME_DATE_REGEX.test str

  @parseGameDateString: (str) =>
    unless @validateGameDateString str
      throw new Error "Cannot parse `#{str}` to GameDate"
    matched = GAME_DATE_REGEX.exec str
    [
      parseInt matched[1], 10
      parseInt matched[2], 10
      parseInt matched[3], 10
    ]

  toString: =>
    "#{_s.pad @year, 8, '0'}#{_s.pad @month, 2, '0'}#{@week}"

  toArray: => [@year, @month, @week]

  # 月と週の桁あふれを計算する、もっと良い書き方が出来そうだけど諦めた
  # e.g.
  #   ('week', 6) -> [1, 2]
  #   ('week', 13) -> [3, 1]
  #   ('week', -1) -> [-1, 3]
  @computeOverflow: (mode, num) ->
    cardinalNum = switch mode
      when 'month' then MAX_MONTH
      when 'week' then MAX_WEEK
    num -= 1  # 月と週共に1開始だから
    secondDigit = parseInt num / cardinalNum, 10
    firstDigit = num % cardinalNum
    if firstDigit < 0
      secondDigit -= 1
      firstDigit += cardinalNum
    [secondDigit, firstDigit + 1]  # 先の 1 を戻す

  # 日付の各値の桁あふれを再計算し、正しい形へ調整する
  @adjustDate: (year, month, week) =>
    [monthDelta, adjustedWeek] = @computeOverflow 'week', week
    [yearDelta, adjustedMonth] = @computeOverflow 'month', month + monthDelta
    adjustedYear = year + yearDelta
    unless MIN_YEAR <= adjustedYear <= MAX_YEAR
      throw new Error "Out of range GameDate(#{year}, #{month}, #{week})"
    [adjustedYear, adjustedMonth, adjustedWeek]

  _adjustDate: =>
    [@_year, @_month, @_week] = @constructor.adjustDate @year, @month, @week

  add: (delta, unit) =>
    switch unit
      when 'years', 'year' then @_year += delta
      when 'months', 'month' then @_month += delta
      when 'weeks', 'week' then @_week += delta
      else throw new Error "Invalid unit=`#{unit}`"  # 'day' 指定してしまうことがあるため
    @_adjustDate()
    @
  subtract: (delta, unit) => @add -delta, unit

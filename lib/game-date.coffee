#
# ゲーム日付モジュール
#

_ = require 'lodash'
_s = require 'underscore.string'


@GameDate = class GameDate

  @MIN_YEAR: 0
  @MAX_YEAR: 99999999
  @MONTHS: [0..11]
  @MIN_MONTH: _.first @MONTHS
  @MAX_MONTH: _.last @MONTHS
  @MONTH_LENGTH: @MONTHS.length
  @WEEKS: [0..3]
  @MIN_WEEK: _.first @WEEKS
  @MAX_WEEK: _.last @WEEKS
  @WEEK_LENGTH: @WEEKS.length

  @monthsToWeeks: (months) -> months * @WEEK_LENGTH
  @yearsToWeeks: (years) -> @monthsToWeeks years * @MONTH_LENGTH
  @ymwToWeeks: (year, month, week) -> @yearsToWeeks(year) + @monthsToWeeks(month) + week

  @FIRST_WEEK: @ymwToWeeks 0, 0, 0
  @LAST_WEEK: @ymwToWeeks @MAX_YEAR, @MAX_MONTH, @MAX_WEEK

  @validateWeeksRange: (weeks) -> @FIRST_WEEK <= weeks <= @LAST_WEEK

  @weeksToWeek: (weeks) -> weeks % @WEEK_LENGTH
  @weeksToMonths: (weeks) -> parseInt weeks / @WEEK_LENGTH, 10
  @weeksToMonth: (weeks) -> @weeksToMonths(weeks) % @MONTH_LENGTH
  @weeksToYears: (weeks) -> parseInt @weeksToMonths(weeks) / @MONTH_LENGTH, 10
  @weeksToYear: (weeks) -> @weeksToYears weeks

  # 月・週はそれぞれ最小値から最大値の範囲を超えても指定できる
  constructor: (any=0) ->
    # weeks 指定
    @_weeks = if _.isNumber(any) and not isNaN(any)
      any
    # [y, m, w] 指定
    else if _.isArray any
      @constructor.ymwToWeeks(
        any[0] ? @constructor.MIN_YEAR
        any[1] ? @constructor.MIN_MONTH
        any[2] ? @constructor.MIN_WEEK
      )
    else
      throw new Error "Cannot initialize GameDate from `#{any}`"

    @_assertValidWeeks()

    Object.defineProperty @, 'year', get: -> @constructor.weeksToYear @_weeks
    Object.defineProperty @, 'month', get: -> @constructor.weeksToMonth @_weeks
    Object.defineProperty @, 'week', get: -> @constructor.weeksToWeek @_weeks

  _assertValidWeeks: =>
    unless @constructor.validateWeeksRange @_weeks
      throw new Error "#{@_weeks} is out of range weeks"

  add: (delta, unit) =>
    switch unit
      when 'years', 'year' then @_weeks += @constructor.yearsToWeeks delta
      when 'months', 'month' then @_weeks += @constructor.monthsToWeeks delta
      when 'weeks', 'week', undefined then @_weeks += delta
      else throw new Error "`#{unit}` is invalid GameDate unit"  # 'day' 指定してしまうことがあるため
    @_assertValidWeeks()
    @
  subtract: (delta, unit) => @add -delta, unit

  toWeeks: -> @_weeks
  toArray: -> [@year, @month, @week]

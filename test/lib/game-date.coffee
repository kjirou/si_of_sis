assert = require 'power-assert'

{GameDate} = require 'lib/game-date'


describe 'game-date Lib', ->

  describe 'GameDate Class', ->

    it 'FIRST_WEEK', ->
      assert GameDate.FIRST_WEEK is 0

    it 'LAST_WEEK', ->
      assert GameDate.LAST_WEEK is GameDate.MAX_YEAR * 12 * 4 + 11 * 4 + 3

    it 'validateWeeksRange', ->
      assert GameDate.validateWeeksRange GameDate.FIRST_WEEK
      assert GameDate.validateWeeksRange GameDate.LAST_WEEK
      assert GameDate.validateWeeksRange(GameDate.FIRST_WEEK - 1) is false
      assert GameDate.validateWeeksRange(GameDate.LAST_WEEK + 1) is false

    it 'weeksToMonth', ->
      assert GameDate.weeksToMonth(0) is 0
      assert GameDate.weeksToMonth(3) is 0
      assert GameDate.weeksToMonth(4) is 1
      assert GameDate.weeksToMonth(7) is 1
      assert GameDate.weeksToMonth(8) is 2
      assert GameDate.weeksToMonth(47) is 11
      assert GameDate.weeksToMonth(48) is 0

    it 'weeksToYear', ->
      assert GameDate.weeksToYear(0) is 0
      assert GameDate.weeksToYear(47) is 0
      assert GameDate.weeksToYear(48) is 1
      assert GameDate.weeksToYear(95) is 1
      assert GameDate.weeksToYear(96) is 2

    it 'constructor / year / month / week / toArray', ->
      d = new GameDate
      assert d.year is 0
      assert d.month is 0
      assert d.week is 0
      assert.deepEqual d.toArray(), [0, 0, 0]

      d = new GameDate 12 * 4 * 1 + 4 * 11 + 3
      assert.deepEqual d.toArray(), [1, 11, 3]
      assert d.year is 1
      assert d.month is 11
      assert d.week is 3

      d = new GameDate [1, 11, 3]
      assert.deepEqual d.toArray(), [1, 11, 3]

      assert.throws ->
        new GameDate -1
      , /-1/

      assert.throws ->
        new GameDate '1'
      , /1/

    it 'add / subtract', ->
      d = new GameDate
      d.add 1, 'week'
      assert.deepEqual d.toArray(), [0, 0, 1]
      d.add 2, 'weeks'
      assert.deepEqual d.toArray(), [0, 0, 3]
      d.add 1  # 単位指定無しは weeks 指定になる
      assert.deepEqual d.toArray(), [0, 1, 0]

      d = new GameDate
      d.add 1, 'month'
      d.add 2, 'months'
      assert.deepEqual d.toArray(), [0, 3, 0]

      d = new GameDate
      d.add 1, 'year'
      d.add 2, 'years'
      assert.deepEqual d.toArray(), [3, 0, 0]

      d = new GameDate
      d.add 1, 'year'
      d.add -1, 'week'
      assert.deepEqual d.toArray(), [0, 11, 3]
      d.subtract 1, 'month'
      assert.deepEqual d.toArray(), [0, 10, 3]

      d = new GameDate
      assert.throws ->
        d.subtract 1
      , /-1/

      # Mathod chain
      d = new GameDate [1, 0, 0]
      assert.deepEqual d.add(1, 'month').subtract(8, 'weeks').toArray(), [0, 11, 0]

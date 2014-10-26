assert = require 'power-assert'

{GameDate} = require 'lib/game-date'


describe 'game-date Lib', ->

  describe 'GameDate Class', ->

    it 'validateGameDateString', ->
      assert GameDate.validateGameDateString '00000000000'
      assert GameDate.validateGameDateString '99999999999'
      assert GameDate.validateGameDateString('0000000000') is false
      assert GameDate.validateGameDateString('000000000000') is false
      assert GameDate.validateGameDateString('0000000000a') is false

    it 'parseGameDateString', ->
      assert.deepEqual GameDate.parseGameDateString('00000000000'), [0, 0, 0]
      assert.deepEqual GameDate.parseGameDateString('99999999999'), [99999999, 99, 9]
      assert.throws ->
        GameDate.parseGameDateString '0000000000a'
      , /0000000000a/

    it 'computeOverflow to week', ->
      assert.deepEqual GameDate.computeOverflow('week', 1), [0, 1]
      assert.deepEqual GameDate.computeOverflow('week', 4), [0, 4]
      assert.deepEqual GameDate.computeOverflow('week', 5), [1, 1]
      assert.deepEqual GameDate.computeOverflow('week', 12), [2, 4]
      assert.deepEqual GameDate.computeOverflow('week', 0), [-1, 4]
      assert.deepEqual GameDate.computeOverflow('week', -3), [-1, 1]
      assert.deepEqual GameDate.computeOverflow('week', -4), [-2, 4]
      assert.deepEqual GameDate.computeOverflow('week', -11), [-3, 1]

    it 'computeOverflow to month', ->
      assert.deepEqual GameDate.computeOverflow('month', 1), [0, 1]
      assert.deepEqual GameDate.computeOverflow('month', 12), [0, 12]
      assert.deepEqual GameDate.computeOverflow('month', 13), [1, 1]
      assert.deepEqual GameDate.computeOverflow('month', 24), [1, 12]
      assert.deepEqual GameDate.computeOverflow('month', 0), [-1, 12]
      assert.deepEqual GameDate.computeOverflow('month', -11), [-1, 1]
      assert.deepEqual GameDate.computeOverflow('month', -12), [-2, 12]

    it 'adjustDate', ->
      assert.deepEqual GameDate.adjustDate(1, 1, 1), [1, 1, 1]
      assert.deepEqual GameDate.adjustDate(99999999, 11, 4), [99999999, 11, 4]
      assert.deepEqual GameDate.adjustDate(1, 1, 5), [1, 2, 1]
      assert.deepEqual GameDate.adjustDate(1, 12, 5), [2, 1, 1]
      assert.deepEqual GameDate.adjustDate(1, 2, 0), [1, 1, 4]
      assert.deepEqual GameDate.adjustDate(2, 1, 0), [1, 12, 4]
      assert.throws ->
        GameDate.adjustDate(1, 1, 0)
      , /GameDate\(1, 1, 0\)/
      assert.throws ->
        GameDate.adjustDate(99999999, 12, 5)
      , /GameDate\(99999999, 12, 5\)/

    it 'constructor', ->
      gameDate = new GameDate
      assert gameDate.year is 1
      assert gameDate.month is 1
      assert gameDate.week is 1

      gameDate = new GameDate 1, 12, 5
      assert gameDate.year is 2
      assert gameDate.month is 1
      assert gameDate.week is 1

      gameDate = new GameDate '00000001011'
      assert gameDate.year is 1
      assert gameDate.month is 1
      assert gameDate.week is 1

      gameDate = new GameDate '00000001125'
      assert gameDate.year is 2
      assert gameDate.month is 1
      assert gameDate.week is 1

    it 'toString', ->
      assert.deepEqual new GameDate(1, 2, 3).toString(), '00000001023'

    it 'toArray', ->
      assert.deepEqual new GameDate(1, 2, 3).toArray(), [1, 2, 3]

    it 'add', ->
      gameDate = new GameDate
      assert gameDate.year is 1
      assert gameDate.month is 1
      assert gameDate.week is 1

      gameDate.add 1, 'year'
      assert gameDate.year is 2
      gameDate.add 2, 'years'
      assert gameDate.year is 4
      gameDate.add 1, 'month'
      assert gameDate.month is 2
      gameDate.add 11, 'months'
      assert gameDate.year is 5
      assert gameDate.month is 1
      gameDate.add 1, 'week'
      assert gameDate.week is 2
      gameDate.add 3, 'weeks'
      assert gameDate.month is 2

      assert.throws ->
        gameDate.add 1, 'day'
      , /day/

    it 'subtract', ->
      gameDate = new GameDate 99999999, 12, 4
      gameDate.subtract 1, 'year'
      gameDate.subtract 1, 'month'
      gameDate.subtract 1, 'week'
      assert.deepEqual gameDate.toArray(), [99999998, 11, 3]

    it 'Method chain', ->
      assert (new GameDate).add(1, 'month').subtract(1, 'week').toString() is '00000001014'

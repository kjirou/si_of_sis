assert = require 'power-assert'

errors = require 'lib/errors'


describe 'errors Lib', ->

  it 'extendError', ->
    MyError = errors.extendError 'MyError'

    assert.throws ->
      throw new MyError 'Hello, my error.'
    , (e) ->
      e instanceof Error and
      e instanceof MyError and
      e.name is 'MyError' and
      e.message is 'Hello, my error.' and
      e.stack.length > 0

    assert.throws ->
      throw new MyError
    , /MyError/

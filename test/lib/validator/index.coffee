assert = require 'power-assert'
_ = require 'underscore'

{defaultErrorMessages, ErrorReporter, Field, Form, validator} = require 'lib/validator'


describe 'validator Lib', ->

  it 'Module definition', ->
    assert typeof defaultErrorMessages is 'object'
    assert _.size(defaultErrorMessages) > 0
    assert typeof ErrorReporter is 'function'
    assert typeof Field is 'function'
    assert typeof Form is 'function'
    assert typeof validator is 'object'

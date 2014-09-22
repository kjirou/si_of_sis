assert = require 'assert'

core = require 'lib/util/core'


describe 'core Util', ->

  it 'bindPathRoot', ->
    # パスが付与されている、他の引数が渡されている
    foo = (path, a, b) -> [path, a, b]
    wrappedFoo = core.bindPathRoot '/path/to', foo
    assert.deepEqual(wrappedFoo('foo', 1, 2), ['/path/to/foo', 1, 2])

    # thisスコープを維持している
    obj =
      x: 2
      foo: (path, y) -> [path, @x * y]
    assert.deepEqual(obj.foo('foo', 3), ['foo', 6])

    obj.bar = core.bindPathRoot 'hoge', obj.foo
    assert.deepEqual(obj.bar('bar', 4), ['hoge/bar', 8])

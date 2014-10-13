async = require 'async'
assert = require 'power-assert'
_ = require 'underscore'

flash = require 'lib/middlewares/extended-connect-flash'


describe 'extended-connect-flash Middleware', ->

  it 'Module definition', ->
    assert typeof flash is 'function'
    middleware = flash()
    assert typeof middleware is 'function'
    {generateFlashKey} = flash
    assert typeof generateFlashKey is 'function'

  it 'generateFlashKey', ->
    {generateFlashKey} = flash
    assert.strictEqual generateFlashKey('foo'), 'foo'
    assert.strictEqual generateFlashKey({ type:'controller', name:'core.index'}), 'controller--core.index--default'
    assert.strictEqual(
      generateFlashKey({ type:'controller', name:'core.index', key:'hello' }),
      'controller--core.index--hello'
    )

  it 'validateFlashKey', ->
    {validateFlashKey} = flash
    assert validateFlashKey('notification')
    assert not validateFlashKey('foo')
    assert validateFlashKey('controller--core.index--default')

  it 'xflashで不正なキーを指定するとエラーになる', ->
    {xflash} = flash
    assert.throws ->
      xflash 'foo', 1
    , /Invalid/

  it 'connect-flashのflashへ値を渡せている', (done) ->
    req = {}
    middleware = flash()
    middleware req, {}, ->
      # メソッドが定義されているか
      assert typeof req.flash is 'function'
      assert typeof req.xflash is 'function'
      # flash へ正しく値が渡されているか
      passedArgs = []
      req.flash = -> passedArgs.push _.toArray(arguments)
      req.xflash 'notification', 'Foo'
      req.xflash 'notification'
      assert.deepEqual passedArgs, [
        ['notification', 'Foo']
        ['notification']
      ]
      done()

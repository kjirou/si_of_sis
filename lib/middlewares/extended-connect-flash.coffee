#
# connect-flash の拡張である xflash を req へ付与する
# flash キーの管理もこの中で行う
#

connectFlash = require 'connect-flash'
_ = require 'underscore'


generateFlashKey = (keyData) ->
  if _.isString keyData
    keyData
  # e.g.
  #   { type: 'controller', name: 'core.index' }
  #   { type: 'controller', name: 'core.index', key: 'messages'}
  else if keyData?.type is 'controller' and keyData?.name
    "#{keyData.type}--#{keyData.name}--#{keyData.key or 'default'}"
  else
    keyData.toString()

# 許可されているパターンのキーかを判定する
# 新しいキーを増やす場合は、ここへパターンとして追加する
validateFlashKey = (key) ->
  [
    # 共通の通知ビューへ表示する値
    /^success$/
    /^failure$/
    /^notification$/
    # あるコントローラ内でのみ参照される値, チェック甘いけどまぁ良い
    # e.g. 'controller--core.index--default', 'controller--foo.bar.baz--your_key'
    /^controller--.+--.+$/
  ].some (matcher) ->
    matcher.test key

# (keyData) or (keyData, value)
xflash = ->
  keyData = arguments[0]
  key = generateFlashKey keyData
  unless validateFlashKey key
    throw new Error 'Invalid flash key'
  @flash.apply @, arguments

createMiddleware = ->
  originalMiddleware = connectFlash()
  (req, res, next) ->
    originalMiddleware req, res, (e) ->
      return next e if e
      req.xflash = xflash
      next()


module.exports = createMiddleware
module.exports.generateFlashKey = generateFlashKey
module.exports.validateFlashKey = validateFlashKey
module.exports.xflash = xflash

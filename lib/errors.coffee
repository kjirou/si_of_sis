# カスタムエラークラスを作成する、孫継承は不可
extendError = (errorName) ->
  class extends Error
    constructor: (message) ->
      @name = errorName
      if message
        @message = message
      else
        @message = "Occured a #{@name}"
      if Error.captureStackTrace?
        Error.captureStackTrace @, @constructor
      super


module.exports =
  extendError: extendError
  Http400Error: extendError 'Http400Error'
  Http404Error: extendError 'Http404Error'
  Http500Error: extendError 'Http500Error'

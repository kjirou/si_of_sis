_ = require 'underscore'
pathModule = require 'path'


module.exports =

  # path を第 1 引数に取る関数をラップして、暗黙的な root path を設定した関数を返す
  # 現在、第 1 引数のみなのは、まずは res.render 用だから
  bindPathRoot: (root, func) ->
    ->
      args = _.toArray arguments
      path = args[0]
      if path?
        args[0] = pathModule.join root, path
      func.apply @, args

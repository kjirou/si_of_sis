mongoose = require 'mongoose'


module.exports =

  purgeDatabase: (callback) ->
    # db 以下の操作は mongoose 側の接続管理が適用されないのでリトライをする
    setTimeout ->
      if mongoose.connection.readyState is 1
        mongoose.connection.db.dropDatabase callback
      else
        setTimeout arguments.callee, 50
    , 1

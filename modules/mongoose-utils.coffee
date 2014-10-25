async = require 'async'
mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
_ = require 'underscore'
validator = require 'validator'


utils =

  isObjectId: (any) ->
    (any instanceof ObjectId) or validator.isMongoId(any)

  # ObjectId か不正な値な場合は null へ変換する
  toObjectIdCondition: (any) ->
    if utils.isObjectId(any) then ObjectId(any) else null

  # DB を削除する, インデックスも消える
  purgeDatabase: (callback) ->
    # db 以下の操作は mongoose 側の接続管理が適用されないのでリトライをする
    setTimeout ->
      if mongoose.connection.readyState is 1
        mongoose.connection.db.dropDatabase callback
      else
        setTimeout arguments.callee, 50
    , 1

  # Model をリストで指定し、順番に remove を実行させる
  executeRemovingToEachModels: (models, callback) ->
    async.eachSeries models, (model, nextLoop) ->
      model.remove nextLoop
    , callback


module.exports = utils

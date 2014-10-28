async = require 'async'
_ = require 'lodash'
mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
validator = require 'validator'


@isObjectId = (any) ->
  (any instanceof ObjectId) or validator.isMongoId(any)

# ObjectId か不正な値な場合は null へ変換する
@toObjectIdCondition = (any) =>
  if @isObjectId(any) then ObjectId(any) else null

# paths に指定したフィールドが populate 実行済みでなければ例外を投げる
@assertPopulated = (doc, paths...) ->
  unless paths.every((path) -> doc.populated path)
    # doc から自分の Model 名は取れないみたい
    # Ref) http://mongoosejs.com/docs/api.html#model_Model
    throw new Error "The document has not populated to #{paths.join(', ')}"

# DB を削除する, インデックスも消える
@purgeDatabase = (callback) ->
  # db 以下の操作は mongoose 側の接続管理が適用されないのでリトライをする
  setTimeout ->
    if mongoose.connection.readyState is 1
      mongoose.connection.db.dropDatabase callback
    else
      setTimeout arguments.callee, 50
  , 1

# Model をリストで指定し、順番に remove を実行させる
@executeRemovingToEachModels = (models, callback) ->
  async.eachSeries models, (model, nextLoop) ->
    model.remove nextLoop
  , callback

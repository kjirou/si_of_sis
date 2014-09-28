mongoose = require 'mongoose'

{Sandbox} = require('apps').models


helper = {}

# 重複しないモデル名でモデルを作成する, 同名モデルは mongoose がエラーにするため
_uniqueModelId = 0
helper.createTestModel = (schema, callback) ->
  _uniqueModelId += 1
  Model = mongoose.model 'Test' + _uniqueModelId, schema
  # 前に dropDatabase しているとインデックスが付与されないことがあるため
  Model.ensureIndexes (e) ->
    return callback e if e
    callback null, Model


module.exports = helper

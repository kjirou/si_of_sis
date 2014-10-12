mongoose = require 'mongoose'
{ObjectId} = mongoose.Types
_ = require 'underscore'

{Company, User} = require('apps').models
mongooseUtil = require 'lib/util/mongoose'


helper = {}

# 重複しないモデル名でモデルを作成する, 同名モデルは mongoose がエラーにするため
_uniqueModelId = 0
helper.createTestModel = (schema, callback) ->
  _uniqueModelId += 1
  Model = mongoose.model 'Test' + _uniqueModelId, schema
  # autoIndex が有効なら明示的にインデックスを張る
  # 前に dropDatabase しているとインデックスが付与されないことがあるため
  if schema.options.autoIndex
    Model.ensureIndexes (e) ->
      return callback e if e
      callback null, Model
  else
    callback null, Model

# 重複しないランダムな ObjectId を作成する
_createdObjectIdStrings = []
helper.createUniqueObjectId = ->
  letters = '0123456789abcdef'
  idStr = null
  while (not idStr?) or (idStr in _createdObjectIdStrings)
    idStr = (letters[_.random letters.length - 1] for i in [0..23]).join ''
  _createdObjectIdStrings.push idStr
  ObjectId idStr

# 削除メソッド群
helper.removeUserCompletely = (callback) ->
  mongooseUtil.executeRemovingToEachModels [Company, User], callback
helper.removeCompanyCompletely = (callback) ->
  mongooseUtil.executeRemovingToEachModels [Company, User], callback


module.exports = helper

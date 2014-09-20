mongoose = require 'mongoose'
{Schema} = mongoose


#
# テスト用データベース
#
SandboxSchema = new Schema {}


module.exports =
  Sandbox: mongoose.model 'Sandbox', SandboxSchema

mongoose = require 'mongoose'
{Schema} = mongoose


#
# テスト用データベース
#
schema = new Schema {}


module.exports = mongoose.model 'Sandbox', schema

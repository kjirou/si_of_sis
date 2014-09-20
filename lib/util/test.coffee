mongoose = require 'mongoose'

config = require 'config'


module.exports =

  purgeDatabase: (callback) ->
    mongoose.connection.db.dropDatabase callback

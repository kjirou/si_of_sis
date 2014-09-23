mongoose = require 'mongoose'


module.exports =

  purgeDatabase: (callback) ->
    mongoose.connection.db.dropDatabase callback

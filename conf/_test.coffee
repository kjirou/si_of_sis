module.exports = (conf) ->

  conf.mongodb.databaseName = 'sos_test'
  conf.server.port = '13000'
  conf.session.mongodbStore.databaseName = 'sos_session_test'

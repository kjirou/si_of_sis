databaseHelper = require 'helpers/database'


describe 'database Helper', ->

  it 'resetDatabase', (done) ->
    databaseHelper.resetDatabase done

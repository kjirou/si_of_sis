async = require 'async'


utils =

  executeRemovingToEachModels: (models, callback) ->
    async.eachSeries models, (model, nextLoop) ->
      model.remove nextLoop
    , callback


module.exports = utils

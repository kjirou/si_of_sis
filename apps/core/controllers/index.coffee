controllers = {}

controllers.index = (req, res, next) ->
  res.render 'apps/core/index'

module.exports = controllers

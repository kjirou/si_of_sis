controllers = {}

controllers.index = (req, res, next) ->
  res.renderSubApp 'index'

module.exports = controllers

controllers = {}

controllers.index = (req, res, next) ->
  res.write 'core.index'
  res.end()

module.exports = controllers

controllers = {}

controllers.index = (req, res, next) ->
  res.send 'company.index'

module.exports = controllers

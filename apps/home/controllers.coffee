controllers = {}

controllers.index = (req, res, next) ->
  res.send "#{req.subApp.name}.index"

controllers.foo = (req, res, next) ->
  res.send "#{req.subApp.name}.foo"

module.exports = controllers

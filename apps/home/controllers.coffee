controllers = {}

controllers.index = (req, res, next) ->
  res.send "#{req.subApp.name}.index"

controllers.foo = (req, res, next) ->
  res.send "#{req.subApp.name}.foo"

controllers.session_counter = (req, res, next) ->
  req.session._counter ?= 0
  req.session._counter += 1
  console.log req.session._counter
  res.redirect '/'

module.exports = controllers

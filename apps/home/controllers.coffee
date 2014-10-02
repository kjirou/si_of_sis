controllers = {}

controllers.index = (req, res, next) ->
  res.renderSubApp 'index'

controllers.session_counter = (req, res, next) ->
  req.session._counter ?= 0
  req.session._counter += 1
  console.log req.session._counter
  res.redirect '/'

module.exports = controllers

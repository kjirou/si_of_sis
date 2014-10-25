_ = require 'lodash'

{Http404Error} = require 'lib/errors'


@allow = (options={}) ->
  options = _.extend {
    # 許可するHTTPメソッドリスト、それ以外は許可されない
    methods: []
  }, options

  (req, res, next) ->
    unless req.method in options.methods
      next new Http404Error "Not allowed #{req.method} method"
    else
      next()

@getOnly = =>
  @allow methods: ['GET']

@postOnly = =>
  @allow methods: ['POST']

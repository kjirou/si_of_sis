chain = require 'connect-chain'
_ = require 'lodash'

logics = require './logics'
{Business} = require './models'
{getOnly} = require 'lib/middlewares/http'


@index = chain getOnly(), (req, res, next) ->
  # @TODO 表示可能案件から受注済みを除いたものを出す予定
  Business.find().sort(raw_closing_week:1).exec (e, businesses) ->
    return next e if e
    res.subApp.render 'index', businesses: businesses

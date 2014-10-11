Rwg = require 'random-word-generator'
_ = require 'underscore'


module.exports =

  createRandomCompanyName: ->
    suffixes = [
      ' & Co.'
      ' Co. Ltd.'
      ' Co. Ltd.'
      ' Inc.'
      ' Inc.'
      ' Inc.'
      ' Inc.'
      ' Ltd.'
      ' Ltd.'
    ]
    (new Rwg).generate() + _.sample(suffixes)

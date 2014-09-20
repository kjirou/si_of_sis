module.exports =

  want: (moduleName) ->
    try
      require moduleName
    catch e
      return null if e.code is 'MODULE_NOT_FOUND'
      throw e

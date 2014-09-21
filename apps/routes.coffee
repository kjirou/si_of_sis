router = require 'express-nested-router'

coreNamespace = require './core/routes'
homeNamespace = require './home/routes'


coreNamespace.addRoute 'home', homeNamespace


module.exports =
  namespace: coreNamespace
  subAppNamespaces:
    core: coreNamespace
    home: homeNamespace

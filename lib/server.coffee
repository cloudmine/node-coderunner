'use strict'
Hapi = require 'hapi'
Boom = require 'boom'
BadRequest = Boom.badRequest
join = require('path').join

class Server

  constructor: ->
    @server = new Hapi.Server()
    @server.connection(port: 4555)
    @_names()

  _names: ->
    @server.route
      method: 'GET'
      path: '/names'
      handler: (req, reply)=>
        return reply(BadRequest('Server Has not been started!')) unless @snippetNames
        reply(names: @snippetNames)

  ###
  The required path is relative to this module...
  ###
  _configure: (context, path)->
    @requiredFile = context.require(path)
    console.log 'file', path
    console.log 'file', @requiredFile
    @snippetNames = Object.keys(@requiredFile)
    @_setupRoutes()

  _setupRoutes: ->
    @server.route
      method: ['PUT', 'POST', 'GET']
      path: '/snippet/{name}'
      handler: (req, reply)=>
        snippet = @requiredFile[req.params.name]
        return reply(BadRequest('Snippet Not Found!')) unless snippet
        snippet(req, reply)

  start: (context, path, cb)->
    throw Error('No Path Given!') unless path
    @_configure(context, path)
    @server.start (err)->
      cb(err) if cb

module.exports = new Server()

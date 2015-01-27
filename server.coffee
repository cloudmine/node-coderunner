'use strict'
Hapi = require 'hapi'
Boom = require 'boom'
BadRequest = Boom.badRequest

class Server

  constructor: ->
    @server = new Hapi.Server()
    @server.connection(port: 80)
    @_names()

  _names: ->
    @server.route
      method: 'GET'
      path: '/names'
      handler: (req, reply)=>
        return reply(BadRequest('Server Has not been started!')) unless @snippetNames
        reply(names: @snippetNames)

  _configure: (path)->
    @requiredFile = require(path)
    @snippetNames = Object.keys(@requiredFile)
    @_setupRoutes()

  _setupRoutes: ->
    @server.route
      method: ['PUT', 'POST', 'GET']
      path: '/snippet/{name}'
      handler: (req, reply)->
        snippet = @requiredFile[req.params.name]
        return reply(BadRequest('Snippet Not Found!')) unless snippet
        snippet(req, reply)

  start: (path, cb = ->)->
    throw Error('No Path Given!') unless path
    @_configure(path)
    @server.start =>
      console.log "Server started at #{@server.info.address}:#{@server.info.port}"
      cb()

module.exports = new Server()

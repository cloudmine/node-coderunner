'use strict'

#
# CloudMine, Inc
# 2015
#

Hapi = require 'hapi'
{badRequest} = require 'boom'
join = require('path').join
{isTruthy: isTruthy, create: createReqPayload} = require './payload'

class Server

  constructor: ->
    @server = new Hapi.Server()
    @server.connection(host: '0.0.0.0', port: process.env.PORT or 4545)

    @server.on 'request-error', (req, err)->
      console.log 'Internal Server Error:', err

    @_names()

  _names: ->
    @server.route
      method: 'GET'
      path: '/names'
      handler: (req, reply)=>
        return reply(badRequest('Server Has not been started!')) unless @snippetNames
        reply(@snippetNames)

  ###
  The required path is relative to this module...
  ###
  _configure: (context, path)->
    @requiredFile = context.require(path)
    @snippetNames = Object.keys(@requiredFile)
    @_setupRoutes()

  _setupRoutes: ->
    if isTruthy process.env['LOCAL_TESTING']
      @server.route
        method: ['PUT', 'POST']
        path: '/v1/app/{appid}/run/{name}'
        config:
          payload:
            maxBytes: 20000000
        handler: (old_req, reply)=>
          snippet = @requiredFile[old_req.params.name]
          return reply(badRequest('Snippet Not Found!')) unless snippet
          req = createReqPayload old_req
          snippet(req, reply)
      @server.route
        method: ['GET']
        path: '/v1/app/{appid}/run/{name}'
        handler: (old_req, reply)=>
          snippet = @requiredFile[old_req.params.name]
          return reply(badRequest('Snippet Not Found!')) unless snippet
          req = createReqPayload old_req
          snippet(req, reply)
    else
      @server.route
        method: ['PUT', 'POST']
        path: '/code/{name}'
        config:
          payload:
            maxBytes: 20000000
        handler: (req, reply)=>
          snippet = @requiredFile[req.params.name]
          return reply(badRequest('Snippet Not Found!')) unless snippet
          snippet(req, reply)
      @server.route
        method: ['GET']
        path: '/code/{name}'
        handler: (req, reply)=>
          snippet = @requiredFile[req.params.name]
          return reply(badRequest('Snippet Not Found!')) unless snippet
          snippet(req, reply)

  start: (context, path, cb)->
    throw Error('No Path Given!') unless path
    @_configure(context, path)
    @server.start (err)->
      cb(err) if cb

module.exports = new Server()

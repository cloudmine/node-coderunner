'use strict'
#
# CloudMine, Inc
# 2015
#

Hapi = require 'hapi'
{badRequest} = require 'boom'
join = require('path').join
data = require './data' 

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
    @server.route
      method: ['PUT', 'POST', 'GET']
      path: '/v1/app/{appid}/run/{name}'
      handler: (req, reply)=>
        snippet = @requiredFile[req.params.name]
        return reply({errors: ["API Key invalid"]})  unless data.goodApiKey req
        return reply(badRequest('Snippet Not Found!')) unless snippet
        snippet(req, reply)

  start: (context, path, cb)->
    throw Error('No Path Given!') unless path
    @_configure(context, path)
    @server.start (err)->
      cb(err) if cb

module.exports = new Server()

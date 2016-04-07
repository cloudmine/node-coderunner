'use strict'

#
# CloudMine, Inc
# 2015
#

Hapi = require 'hapi'
{badRequest} = require 'boom'
join = require('path').join
{isTruthy: isTruthy, create: createReqPayload} = require './remote_payload'

MAX_PAYLOAD_BYTES = 20000000

class Server

  constructor: ->
    @server = new Hapi.Server()
    @server.connection(host: '0.0.0.0', port: process.env.PORT or 4545)
    @server.on 'request-error', (req, err)->
      console.log 'Internal Server Error:', err

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

  ###
  We need local testing to behave the same as when the code is deployed on the PaaS but
  normally coderunner does a bunch of work as the middleman. We recreate a lot of that logic
  here and flip the local switch via an environment variable.
  ###
  _setupRoutes: ->
    @_names()
    if isTruthy process.env['LOCAL_TESTING']
      @_setupLocalTestingRoutes()
    else
      @_setupDeployedRoutes()

  _setupLocalTestingRoutes: ->
    # Respond to the same routes that our external api would. f= not currently supported
    paths = ['/v1/app/{appid}/run/{name}',
             '/v1/app/{appid}/user/run/{name}',
             '/v1/app/{appid}/user/{userId}/run/{name}']
    # The local testing handler replaces the request object with one that conforms to what
    # a deployed snippet would expect, simulating the transformations done by coderunner
    localTestingHandler = (old_req, reply)=>
      snippet = @requiredFile[old_req.params.name]
      return reply(badRequest('Snippet Not Found!')) unless snippet
      req = createReqPayload old_req
      snippet(req, reply)

    @_setupPutAndPostRoute path, localTestingHandler for path in paths
    @_setupGetRoute path, localTestingHandler for path in paths


  _setupDeployedRoutes: ->
    path = '/code/{name}'
    deployedHandler = (req, reply)=>
      snippet = @requiredFile[req.params.name]
      return reply(badRequest('Snippet Not Found!')) unless snippet
      snippet(req, reply)

    @_setupPutAndPostRoute path, deployedHandler
    @_setupGetRoute path, deployedHandler


  _setupPutAndPostRoute: (path, handler) ->
    @server.route
      method: ['PUT', 'POST']
      path: path
      config:
        payload:
          maxBytes: MAX_PAYLOAD_BYTES
      handler: handler

  _setupGetRoute: (path, handler) ->
    @server.route
      method: ['GET']
      path: path
      handler: handler

  start: (context, path, cb)->
    throw Error('No Path Given!') unless path
    @_configure(context, path)
    @server.start (err)->
      cb(err) if cb

module.exports = new Server()

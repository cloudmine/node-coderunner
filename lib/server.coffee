'use strict'

#
# CloudMine, Inc
# 2015
#

Hapi = require 'hapi'
{badRequest} = require 'boom'
join = require('path').join
{isTruthy: isTruthy, create: createReqPayload} = require './remote_payload'
localReply = require './local_reply'

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
    # CLOUDMINE should be undefined or 1. Set to 1 on live remote deployments so we can tell the
    # difference from local user testing.
    if isTruthy process.env['CLOUDMINE']
      @_setupDeployedRoutes()
    else
      @_setupLocalTestingRoutes()

  _setupLocalTestingRoutes: ->
    # Respond to the same routes that our external api would. f= not currently supported
    paths = ['/v1/app/{appid}/run/{name}',
             '/v1/app/{appid}/user/run/{name}',
             '/v1/app/{appid}/user/{userId}/run/{name}']
    # The local testing handler replaces the request object with one that conforms to what
    # a deployed snippet would expect, simulating the transformations done by coderunner.
    # It also replaces the reply function for the same purpose.
    localTestingHandler = (original_req, reply)=>
      snippet = @requiredFile[original_req.params.name]
      return reply(badRequest('Snippet Not Found!')) unless snippet
      req = createReqPayload original_req
      snippet(req, localReply(reply, isTruthy(original_req.query.unwrap_result)))

    SNIPPET_TIMEOUT = 30000
    @_setupPutAndPostRoute path, localTestingHandler, SNIPPET_TIMEOUT for path in paths
    @_setupGetRoute path, localTestingHandler, SNIPPET_TIMEOUT for path in paths


  _setupDeployedRoutes: ->
    path = '/code/{name}'
    deployedHandler = (req, reply)=>
      snippet = @requiredFile[req.params.name]
      return reply(badRequest('Snippet Not Found!')) unless snippet
      snippet(req, reply)

    @_setupPutAndPostRoute path, deployedHandler
    @_setupGetRoute path, deployedHandler


  # Setup routes that respond to PUT and POST. MAX_PAYLOAD_BYTES set to allow larger uploads.
  # timeout is set in the local testing case, or null in the live deployed case where timeouts are
  # controlled by coderunner
  _setupPutAndPostRoute: (path, handler, timeout) ->
    @server.route
      method: ['PUT', 'POST']
      path: path
      config:
        payload:
          maxBytes: MAX_PAYLOAD_BYTES
        timeout:
          server: timeout or null
      handler: handler

  # Setup routes that respond to GET. timeout is set in the local testing case,
  # or null in the live deployed case where timeouts are controlled by coderunner
  _setupGetRoute: (path, handler, timeout) ->
    @server.route
      method: ['GET']
      path: path
      handler: handler
      config:
        timeout:
          server: timeout or null

  start: (context, path, cb)->
    throw Error('No Path Given!') unless path
    @_configure(context, path)
    @server.start (err)->
      cb(err) if cb

module.exports = new Server()

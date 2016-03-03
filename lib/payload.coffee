'use strict'
#
# CloudMine, Inc
# 2016
#
_ = require 'lodash'

DEFAULT_TIMEOUT_MS = 30000
DEFAULT_BACKEND_VERSION = 1

isTruthy = (value = '') ->
  value.toString().toLowerCase() in ['true', 't', '1', 'yes']

getReqPayload = (origReqPayload, contentType) ->
  # json or form payloads will get merged into params
  if contentType?.indexOf('application/json') is 0 or
      contentType?.indexOf('application/x-www-form-urlencoded') is 0 or
      contentType?.indexOf('multipart/form-data') is 0
    reqPayload = origReqPayload
  reqPayload = {} unless reqPayload
  reqPayload

getExecutionParams = (reqQuery, reqPayload) ->
  if reqQuery.f
    execParams = {}
    if reqQuery.params
      try
        execParams = JSON.parse(reqQuery.params)
      catch e
        execParams = reqQuery.params #as handled in platform
  else
    execParams = _.assign {}, reqPayload, reqQuery
    delete execParams.apikey if execParams.apikey
  execParams

create = (req) ->
  reqPayload = getReqPayload req, req.headers['content-type']
  params = getExecutionParams req.query, reqPayload

  deisRequestBody =
    request:
      body: if _.isEmpty(reqPayload) then '' else reqPayload
      method: req.method.toUpperCase()
      'content-type': req.headers['content-type']
    response:
      body:
        request:
          method: req.method.toUpperCase()
          'content-type': req.headers['content-type']
    session: # TODO: figure out why these aren't populating
      api_key: req.headers['x-cloudmine-apikey'] or req.query.apikey
      app_id: req.params.appid
      session_token: req.headers['x-cloudmine-sessiontoken'] or null
#      user_id: snippetConfig.userId -- needs platform request
    params: if _.isEmpty(params) then null else params
    config:
      async: isTruthy req.query.async
#      timeout: getExecTimeout snippetConfig.timeout -- needs platform request
#      version: if snippetConfig.backend_version then parseInt(snippetConfig.backend_version) else DEFAULT_BACKEND_VERSION -- needs platform request
      type: 'post' 
    code: undefined 
#  deisRequestBody.response.body = a.platformResult if a.platformResult -- requires platform request
  new_req = {payload: deisRequestBody}
  new_req

module.exports = {isTruthy: isTruthy, create: create}

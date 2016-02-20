'use strict'
#
# CloudMine, Inc
# 2015
#

goodApiKey = (req) ->
  headers = Object.keys req.headers
  "x-cloudmine-apikey" in headers

_empty = (obj) ->
  Object.keys(obj).length == 0

addData = (req) ->
  payload = if req.payload? then req.payload else {}
  req.data = {
    apikey: req.headers["x-cloudmine-apikey"]
    request: {
      method: req.method.toUpperCase()
    }
    input: payload
    params: if _empty(req.query) then payload else req.query
  }

  if not _empty(payload) then req.data.request["content-type"] = req.mime

module.exports = { add: addData, goodApiKey: goodApiKey }

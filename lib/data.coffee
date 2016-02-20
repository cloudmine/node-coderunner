'use strict'
#
# CloudMine, Inc
# 2015
#

goodApiKey = (req) ->
  headers = Object.keys req.headers
  "x-cloudmine-apikey" in headers

addData = (req) ->
  req.data = {
    apikey: req.headers["x-cloudmine-apikey"]
    request: {
      method: req.method.toUpperCase()
    }
    params: req.query
  }

module.exports = { add: addData, goodApiKey: goodApiKey }

'use strict'
#
# CloudMine, Inc
# 2015
#

goodApiKey = (req) ->
  headers = Object.keys req.headers
  "x-cloudmine-apikey" in headers

module.exports = { goodApiKey: goodApiKey }

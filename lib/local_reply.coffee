'use strict'

#
# CloudMine, Inc
# 2015
#

# Wraps the hapi reply function such that we can wrap
# the payload with a 'result' property if necessary
localReply = (reply, unwrapResult) ->
  return reply if unwrapResult
  wrappedReply = ->
    if arguments.length is 2
      err = arguments[0]
      payload = arguments[1]
    else
      payload = arguments[0]
    payload = result: payload
    return reply(err, payload) if err
    reply(payload)

module.exports = localReply

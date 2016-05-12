'use strict'

#
# CloudMine, Inc
# 2015
#

_ = require 'lodash'
Hapi = require 'hapi'
should = require('chai').should()

describe 'Server', ->
  Server = null

  describe 'Starting', ->
    beforeEach ->
      # Since the require creates the server and the module is cached,
      # Remove it from the cache and re-require between tests
      Server = require '../../lib/server'

    afterEach ->
      delete require.cache[require.resolve('../../lib/server')]
      Server = null

    it 'should work with a Path', ->
      Server.start module, '../data/index'

    it 'should callback', (done)->
      Server.start module, '../data/index', ->
        done()

  describe 'Deployed API', ->
    before (done)->
      Server = require '../../lib/server'
      Server.start module, '../data/index', ->
        done()

    after ->
      delete require.cache[require.resolve('../../lib/server')]
      Server = null

    it 'should give the names', (done)->

      req =
        method: 'GET'
        url: '/names'

      Server.server.inject req, (res)->
        res.result.should.deep.equal ['test1', 'test2', 'getPayload']
        done()

    it 'should run the snippet with GET', (done)->
      req =
        method: 'GET'
        url: '/code/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should run the snippet with POST', (done)->
      req =
        method: 'POST'
        url: '/code/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should run the snippet with PUT', (done)->
      req =
        method: 'PUT'
        url: '/code/test1'

      Server.server.inject req, (res)->
        res.result.should.deep.equal 'Hello'
        done()

    it 'should propogate XUniqueID', (done)->
      req =
        method: 'GET'
        url: '/code/test2'
        headers:
          'Content-Type': 'application/json'
          'X-Unique-ID': 'uniqueid'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        global._$XUniqueID.should.equal 'uniqueid'
        done()



  describe 'Local Testing API', ->
    before (done)->
      process.env['LOCAL_TESTING'] = true
      Server = require '../../lib/server'
      Server.start module, '../data/index', ->
        done()


    it 'should propogate XUniqueID', (done)->
      req =
        method: 'GET'
        url: '/v1/app/myappid/run/test2'
        headers:
          'Content-Type': 'application/json'
          'X-Unique-ID': 'uniqueid'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        global._$XUniqueID.should.equal 'uniqueid'
        done()

    it 'should not crash if XUniqueID is not provided', (done)->
      req =
        method: 'GET'
        url: '/v1/app/myappid/run/test2'
        headers:
          'Content-Type': 'application/json'
      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        global._$XUniqueID.should.equal null
        done()



    it 'should give the names', (done)->

      req =
        method: 'GET'
        url: '/names'

      Server.server.inject req, (res)->
        res.result.should.deep.equal ['test1', 'test2', 'getPayload']
        done()

    it 'should 404 the deployed API routes', (done)->
      req =
        method: 'GET'
        url: '/code/test2'

      Server.server.inject req, (res)->
        res.statusCode.should.equal 404
        done()

    it 'should 404 on a non-existent snippet', (done)->
      req =
        method: 'GET'
        url: '/code/notreal'

      Server.server.inject req, (res)->
        res.statusCode.should.equal 404
        done()

    it 'should run the snippet with GET', (done)->
      req =
        method: 'GET'
        url: '/v1/app/myappid/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should run the snippet with POST', (done)->
      req =
        method: 'POST'
        url: '/v1/app/myappid/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should run the snippet with PUT', (done)->
      req =
        method: 'PUT'
        url: '/v1/app/myappid/run/test1'

      Server.server.inject req, (res)->
        res.result.should.deep.equal 'Hello'
        done()

    it 'should allow user based GET requests without user id', (done)->
      req =
        method: 'GET'
        url: '/v1/app/myappid/user/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should allow user based POST requests without user id', (done)->
      req =
        method: 'POST'
        url: '/v1/app/myappid/user/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should allow to user based PUT requests without user id', (done)->
      req =
        method: 'PUT'
        url: '/v1/app/myappid/user/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should allow to user based GET requests with user id', (done)->
      req =
        method: 'GET'
        url: '/v1/app/myappid/user/myUser/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should allow to user based POST requests with user id', (done)->
      req =
        method: 'POST'
        url: '/v1/app/myappid/user/myUser/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()

    it 'should allow to user based PUT requests with user id', (done)->
      req =
        method: 'PUT'
        url: '/v1/app/myappid/user/myUser/run/test2'

      Server.server.inject req, (res)->
        res.result.should.deep.equal some: 'json'
        done()


    describe 'Payload', ->
      baseExpectedPayload =
        request:
          body: ''
          method: 'GET'
          'content-type': 'application/json'
        response:
          body:
            request:
              method: 'GET'
              'content-type': 'application/json'
        session:
          app_id: 'myappid'
          api_key: 'notagoodwaytogo'
          session_token: null
          user_id: '[User ID not populated in local deployments]'
        params: null
        config:
          async: false
          timeout: 30
          version: 2
          type: 'post'
        code: undefined


      it 'should transform the payload to match the transformations done by coderunner', (done)->
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload'
          headers:
            'Content-Type': 'application/json'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          res.result.should.deep.equal baseExpectedPayload
          done()

      it 'should populate the api_key if it was provided in the query string', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.session.api_key = 'queryAPIKey'
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload?apikey=queryAPIKey'
          headers:
            'Content-Type': 'application/json'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should populate the session token if it was provided via header', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.session.session_token = 'mysession'
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload'
          headers:
            'Content-Type': 'application/json'
            'X-CloudMine-APIKey': 'notagoodwaytogo'
            'X-CloudMine-SessionToken': 'mysession'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should provide the payload as params if it was json', (done)->
        requestPayload =
          oneThing: 'this is text'
          theAnswer: 42
          anObject:
            speakTheTruth: true

        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request.method = 'POST'
        expectedPayload.response.body.request.method = 'POST'
        expectedPayload.request.body = requestPayload
        expectedPayload.params = requestPayload
        req =
          method: 'POST'
          url: '/v1/app/myappid/run/getPayload'
          payload: requestPayload
          headers:
            'Content-Type': 'application/json'
            'X-CloudMine-APIKey': 'notagoodwaytogo'
        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should merge query params into the provided params', (done)->
        requestPayload =
          bodyParam: 'this is in the body'

        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request.method = 'POST'
        expectedPayload.response.body.request.method = 'POST'
        expectedPayload.request.body = requestPayload
        expectedPayload.params = _.merge({}, requestPayload, queryParam: 'inTheQuery')
        req =
          method: 'POST'
          url: '/v1/app/myappid/run/getPayload?queryParam=inTheQuery'
          payload: requestPayload
          headers:
            'Content-Type': 'application/json'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          try
            res.result.should.deep.equal expectedPayload
          catch e
            done(e)
            throw e
          done()

      it 'should not merge body params with query params for f= snippets', (done)->
        requestPayload =
          objectKey:
            someText: 'this is in the body'

        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request.method = 'POST'
        expectedPayload.response.body.request.method = 'POST'
        expectedPayload.request.body = requestPayload
        expectedPayload.params = queryParam: 'inTheQuery'
        req =
          method: 'POST'
          url: '/v1/app/myappid/run/getPayload?f=getPayload&params={"queryParam": "inTheQuery"}'
          payload: requestPayload
          headers:
            'Content-Type': 'application/json'
            'X-CloudMine-APIKey': 'notagoodwaytogo'
        Server.server.inject req, (res)->
          try
            res.result.should.deep.equal expectedPayload
          catch e
            done(e)
            throw e
          done()

      it 'should permit application/x-www-form-urlencoded', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request['content-type'] = 'application/x-www-form-urlencoded'
        expectedPayload.response.body.request['content-type'] = 'application/x-www-form-urlencoded'
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload'
          headers:
            'Content-Type': 'application/x-www-form-urlencoded'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should permit multipart/form-data', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request['content-type'] = 'multipart/form-data'
        expectedPayload.response.body.request['content-type'] = 'multipart/form-data'
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload'
          headers:
            'Content-Type': 'multipart/form-data'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should permit text/plain', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request['content-type'] = 'text/plain'
        expectedPayload.response.body.request['content-type'] = 'text/plain'
        req =
          method: 'GET'
          url: '/v1/app/myappid/run/getPayload'
          headers:
            'Content-Type': 'text/plain'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

      it 'should leave text/plain payloads as the exact text that was sent', (done)->
        expectedPayload = _.cloneDeep baseExpectedPayload
        expectedPayload.request.method = 'POST'
        expectedPayload.request['content-type'] = 'text/plain'
        expectedPayload.response.body.request.method = 'POST'
        expectedPayload.response.body.request['content-type'] = 'text/plain'
        expectedPayload.request.body = 'the greatest payload EVER'
        req =
          method: 'POST'
          url: '/v1/app/myappid/run/getPayload'
          payload: 'the greatest payload EVER'
          headers:
            'Content-Type': 'text/plain'
            'X-CloudMine-APIKey': 'notagoodwaytogo'

        Server.server.inject req, (res)->
          res.result.should.deep.equal expectedPayload
          done()

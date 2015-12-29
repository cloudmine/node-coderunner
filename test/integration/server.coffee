'use strict'
#
# CloudMine, Inc
# 2015
#

Hapi = require 'hapi'
should = require('chai').should()
Server = require '../../lib/server'

describe 'Server', ->

  describe 'Starting', ->
    beforeEach ->
      Server.server = new Hapi.Server()
      Server.server.connection()

    it 'should work with a Path', ->
      Server.start(module, '../data/index')

    it 'should callback', (done)->
      Server.start module, '../data/index', ->
        done()

    describe 'API', ->
      api = null
      beforeEach (done)->
        Server._names()
        Server.start module, '../data/index', ->
          done()

      it 'should give the names', (done)->

        req =
          method: 'GET'
          url: '/names'

        Server.server.inject req, (res)->
          res.result.should.deep.equal ['test1', 'test2']
          done()

      it 'should run the snippet', (done)->
        req =
          method: 'GET'
          url: '/code/test2'

        Server.server.inject req, (res)->
          res.result.should.deep.equal some: 'json'
          done()

  afterEach (done)->
    Server.server.stop done

Hapi = require 'hapi'
supertest = require 'supertest'
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
          api = supertest "localhost:#{Server.server.info.port}"
          done()

      it 'should give the names', (done)->
          api.get('/names').end (err, res)->
            res.body.should.deep.equal names: ['test1', 'test2']
            done()

      it 'should run the snippet', (done)->
        api.get('/snippet/test2').end (err, res)->
          res.body.should.deep.equal some: 'json'
          done()

  afterEach (done)->
    Server.server.stop done

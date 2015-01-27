Hapi = require 'hapi'
supertest = require 'supertest'

should = require('chai').should()
Server = require '../../server'


describe 'Server', ->

  it 'should exist', ->
    should.exist Server

  it 'should throw an error with no path', ->
    (-> Server.start() ).should.throw /No Path/


  describe 'Starting', ->

    beforeEach ->
      Server.server = new Hapi.Server()
      Server.server.connection()

    it 'should work with a Path', ->
      Server.start('./test/data/index')

    it 'should callback', (done)->
      Server.start './test/data/index', ->
        done()

    describe 'API', ->

      api = null
      beforeEach (done)->
        Server._names()
        Server._configure('./test/data/index')
        Server.start './test/data/index', ->
          api = supertest "localhost:#{Server.server.info.port}"
          done()

      it 'should give the names', (done)->
          api.get('/names').end (err, res)->
            res.body.should.deep.equal names: ['test1', 'test2']
            done()

      it 'should run the snippet', (done)->
        Server._configure()
        api.get('/snippet/test2').end (err, res)->
          res.body.should.deep.equal some: 'json'
          done()

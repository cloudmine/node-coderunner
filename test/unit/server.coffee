should = require('chai').should()
Server = require '../../lib/server'

describe 'Server', ->

  it 'should exist', ->
    should.exist Server

  it 'should throw an error with no path', ->
    (-> Server.start() ).should.throw /No Path/

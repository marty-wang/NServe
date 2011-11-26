should = require 'should'
sinon = require 'sinon'

connectWebService = require '../lib/connect-webservice'

describe 'connect-webservice', ->
    describe '#connect', ->
        it 'should return a function', ->
            connect = connectWebService.connect()
            connect.should.be.a 'function'
        describe 'if the request url is recognized as web service url', ->
            testErrorFile = 'testErrorFile'
            testWSFolder = 'ws'
            testUrl = "/#{testWSFolder}/data"
            testWS = respond: ->
            respondStub = null

            beforeEach ->
                respondStub = sinon
                    .stub(testWS, 'respond')
            afterEach ->
                respondStub.restore()

            it 'should respond if it is a GET request', ->
                testReq =
                    url: testUrl
                    method: 'GET'
                    query:
                        error: testErrorFile

                connect = connectWebService.connect testWS, testWSFolder

                connect testReq, null

                respondStub.calledWith(testReq, null, testErrorFile).should.be.true

            it 'should respond if it is a POST request', ->
                testReq =
                    url: testUrl
                    method: 'POST'
                    body:
                        error: testErrorFile

                connect = connectWebService.connect testWS, testWSFolder

                connect testReq, null

                respondStub.calledWith(testReq, null, testErrorFile).should.be.true

            it 'should call next if it is other request', ->
                testReq = method: 'otherMethod'
                nextSpy = sinon.spy()

                connect = connectWebService.connect testWS, testWSFolder

                connect testReq, null, nextSpy

                nextSpy.calledOnce.should.be.true
        describe 'if the request url is not recognized as web service url', ->
            it 'should call next', ->
                testWSFolder = 'ws'
                testNonWSUrl = "/non-ws/data"
                testReq = url: testNonWSUrl
                nextSpy = sinon.spy()

                connect = connectWebService.connect null, testWSFolder

                connect testReq, null, nextSpy

                nextSpy.calledOnce.should.be.true

should = require 'should'
sinon = require 'sinon'

fs = require 'fs'
path = require 'path'

webservice = require '../lib/webservice'

describe 'webservice', ->
    testError = new Error()
    testRoot = '/root'
    testUrl = "http://localhost/file/data"
    testDataFilePath = '/root/file/data'
    testErrorFile = 'errorFile'
    testErrorFilePath = '/root/file/errorFile'
    testTimeout = 1000
    testReq = url: testUrl
    testRes =
        writeHead: ->
        end: ->
    testResHeader =
        'Content-Type': "text/plain"
        'Access-Control-Allow-Origin': '*' # for cross-domain ajax
        'Access-Control-Allow-Headers': 'X-Requested-With'
    testData = 'test data'
    errorData = 'error data'

    describe '#respond', ->
        writeHeadStub = null
        endStub = null
        clock = null

        beforeEach ->
            writeHeadStub = sinon.stub(testRes, 'writeHead')
            endStub = sinon.stub(testRes, 'end')
            clock = sinon.useFakeTimers()
        afterEach ->
            writeHeadStub.restore()
            endStub.restore()
            clock.restore()

        describe 'a 1000ms delayed web service', ->
            ws = null
            beforeEach ->
                ws = webservice.create testRoot, testTimeout

            describe 'it it fails to read file', ->
                it 'should response with 404 after 1000ms', ->
                    readFileStub = sinon
                        .stub(fs, 'readFile')
                        .callsArgWith(1, testError)

                    ws.respond testReq, testRes
                    clock.tick testTimeout+100

                    writeHeadStub.calledWith(404, testResHeader).should.be.true

                    readFileStub.restore()

            describe 'if there is no error file and it succeeds to read the data file', ->
                it 'should read the data file after 1000ms', ->
                    readFileStub = sinon
                        .stub(fs, 'readFile')

                    ws.respond testReq, testRes
                    clock.tick testTimeout+100

                    readFileStub.calledWith(testDataFilePath).should.be.true

                    readFileStub.restore()

                it 'should response with 200 and end with file data after 1000ms', ->
                    readFileStub = sinon
                        .stub(fs, 'readFile')
                        .callsArgWith(1, null, testData)

                    ws.respond testReq, testRes
                    clock.tick testTimeout+100

                    writeHeadStub.calledWith(200, testResHeader).should.be.true
                    endStub.calledWith(testData).should.be.true

                    readFileStub.restore()

            describe 'if there is error file and it succeeds to read the error file', ->
                it 'should read the error file under the same folder of the data file after 1000ms', ->
                    readFileStub = sinon
                        .stub(fs, 'readFile')

                    ws.respond testReq, testRes, testErrorFile
                    clock.tick testTimeout+100

                    readFileStub.calledWith(testErrorFilePath).should.be.true

                    readFileStub.restore()

                it 'should response with 404 and end with error data after 1000ms', ->
                    readFileStub = sinon
                        .stub(fs, 'readFile')
                        .callsArgWith(1, null, errorData)

                    ws.respond testReq, testRes, testErrorFile
                    clock.tick testTimeout+100

                    writeHeadStub.calledWith(404, testResHeader).should.be.true
                    endStub.calledWith(errorData).should.be.true

                    readFileStub.restore()

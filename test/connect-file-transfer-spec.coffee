should = require 'should'
sinon = require 'sinon'

connectFileTransfer = require '../lib/connect-file-transfer'

describe 'connect-file-transfer', ->
    describe '#connect', ->
        testRoot = '/root'
        testPathname = '/path/name'
        testFilepath = testRoot + testPathname
        testUrl = 'http://localhost' + testPathname
        testError = new Error()

        it 'should return a function', ->
            connect = connectFileTransfer.connect()
            connect.should.be.a 'function'

        it 'should use file transferer to transfer the file if it is GET request', ->
            testReq =
                method: 'GET'
                url: testUrl
            fileTransferer = transfer: ->
            spy = sinon.spy fileTransferer, 'transfer'
            connect = connectFileTransfer.connect fileTransferer, testRoot

            connect testReq

            spy.calledWith(testFilepath).should.be.true

        it 'should use file transferer to transfer the file if it is POST request', ->
            testReq =
                method: 'POST'
                url: testUrl
            fileTransferer = transfer: ->
            spy = sinon.spy fileTransferer, 'transfer'
            connect = connectFileTransfer.connect fileTransferer, testRoot

            connect testReq

            spy.calledWith(testFilepath).should.be.true

        it 'should call next if it is other request', ->
            testReq = method: 'otherMethod'
            connect = connectFileTransfer.connect()
            nextSpy = sinon.spy()

            connect testReq, null, nextSpy

            nextSpy.calledOnce.should.be.true

        describe 'if file transferer failed to transfer file', ->
            testReq =
                method: 'GET'
                url: testUrl

            it 'should call back with error and call next', (done) ->
                fileTransferer =
                    transfer: (filepath, callback) ->
                        callback testError
                nextSpy = sinon.spy()

                connect = connectFileTransfer.connect fileTransferer, testRoot, (err, data) ->
                        done()
                        err.should.eql testError
                        nextSpy.calledOnce.should.be.true

                connect testReq, null, nextSpy

        describe 'if file transferer succeeds to transfer file', ->
            testContent = 'test content'
            testReq =
                method: 'GET'
                url: testUrl

            it 'should call back with "start" status and response should writehead 200 when file transfer starts to transfer', (done) ->
                fileTransferer =
                    transfer: (filepath, callback) ->
                        callback null, {
                            status: 'start'
                        }
                testRes = writeHead: ->
                writeHeadStub = sinon.stub(testRes, 'writeHead')

                connect = connectFileTransfer.connect fileTransferer, testRoot, (err, data) ->
                    done()
                    should.not.exist err
                    data.should.have.property 'status', 'start'
                    writeHeadStub.calledWith(200).should.be.true

                connect testReq, testRes

            it 'should call response to write content sent by file transferer when it transfers', () ->
                fileTransferer =
                    transfer: (filepath, callback) ->
                        callback null, {
                            status: 'transfer'
                            content: testContent
                        }

                testRes = write: ->
                writeStub = sinon.stub(testRes, 'write')

                connect = connectFileTransfer.connect fileTransferer, testRoot
                connect testReq, testRes

                writeStub.calledWith(testContent).should.be.true

            it 'should call response to end with content sent by file transferer and call back with "complete" status when file transferer completes', (done) ->
                fileTransferer =
                    transfer: (filepath, callback) ->
                        callback null, {
                            status: 'complete'
                            content: testContent
                        }

                testRes = end: ->
                endStub = sinon.stub(testRes, 'end')

                connect = connectFileTransfer.connect fileTransferer, testRoot, (err, data) ->
                    done()
                    should.not.exist err
                    data.should.have.property 'status', 'complete'
                    endStub.calledWith(testContent).should.be.true

                connect testReq, testRes

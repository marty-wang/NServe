vows = require 'vows'
should = require 'should'
sinon = require 'sinon'

connectFileTransfer = require '../lib/connect-file-transfer'

testRoot = "testRoot"
testUrl = "testUrl"
testError = new Error()
    
testResponse =
    writeHead: ->
    write: ->
    end: ->

vows.describe('connect-file-transfer')
    .addBatch(
        '*transfer*':
            'should return a function': ->
                fileTransferer = {
                    transfer: ->
                }
                callback = sinon.spy()
                cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback
                cTransfer.should.be.a 'function'
            
            'for GET request':
                'if there is error, it should callback once and afterwards call next': ->
                    fileTransferer = {
                        transfer: ->
                    }
                    callback = sinon.spy()
                    cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                    fileTransferStub = sinon
                        .stub(fileTransferer, 'transfer')
                        .callsArgWith 1, testError, null

                    req =
                        method: 'GET'
                        url: testUrl
                    
                    nextSpy = sinon.spy()
                    cTransfer req, testResponse, nextSpy

                    callback.calledOnce.should.be.true
                    callback.calledWith(testError).should.be.true
                    nextSpy.calledOnce.should.be.true
                    nextSpy.calledAfter(callback).should.be.true

                    fileTransferStub.restore()
                
                'if there is no error':
                    'when it starts to transfer, response should writeHead and it callback for start status': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        startPayload = {
                            status: 'start'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, startPayload

                        resWriteHeadSpy = sinon.spy testResponse, 'writeHead'
                        req =
                            method: 'GET'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resWriteHeadSpy.calledOnce.should.be.true
                        resWriteHeadSpy.calledWith(200).should.be.true

                        callback.calledOnce.should.be.true
                        args = callback.getCall(0).args
                        should.not.exist args[0]
                        args[1].should.have.property 'status', 'start'

                        fileTransferStub.restore()
                        resWriteHeadSpy.restore()

                    'when it is transfering, response should write the content n times': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        transferPayload = {
                            status: 'transfer'
                            content: 'some content'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, transferPayload

                        resWriteSpy = sinon.spy testResponse, 'write'
                        req =
                            method: 'GET'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resWriteSpy.calledWith(transferPayload.content).should.be.true

                        callback.called.should.be.false

                        fileTransferStub.restore()
                        resWriteSpy.restore()

                    'when it completes, response should end with the content and callback with complete status': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        compelePayload = {
                            status: 'complete'
                            content: 'some content'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, compelePayload

                        resEndSpy = sinon.spy testResponse, 'end'
                        req =
                            method: 'GET'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resEndSpy.calledWith(compelePayload.content).should.be.true

                        callback.calledOnce.should.be.true
                        args = callback.getCall(0).args
                        should.not.exist args[0]
                        args[1].should.have.property 'status', 'complete'

                        fileTransferStub.restore()
                        resEndSpy.restore()
            
            'for POST request':
                'if there is error, it should callback once and afterwards call next': ->
                    fileTransferer = {
                        transfer: ->
                    }
                    callback = sinon.spy()
                    cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                    fileTransferStub = sinon
                        .stub(fileTransferer, 'transfer')
                        .callsArgWith 1, testError, null

                    req =
                        method: 'POST'
                        url: testUrl
                    
                    nextSpy = sinon.spy()
                    cTransfer req, testResponse, nextSpy

                    callback.calledOnce.should.be.true
                    callback.calledWith(testError).should.be.true
                    nextSpy.calledOnce.should.be.true
                    nextSpy.calledAfter(callback).should.be.true

                    fileTransferStub.restore()
                'if there is no error':
                    'when it starts to transfer, response should writeHead and it callback for start status': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        startPayload = {
                            status: 'start'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, startPayload

                        resWriteHeadSpy = sinon.spy testResponse, 'writeHead'
                        req =
                            method: 'POST'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resWriteHeadSpy.calledOnce.should.be.true
                        resWriteHeadSpy.calledWith(200).should.be.true

                        callback.calledOnce.should.be.true
                        args = callback.getCall(0).args
                        should.not.exist args[0]
                        args[1].should.have.property 'status', 'start'

                        fileTransferStub.restore()
                        resWriteHeadSpy.restore()

                    'when it is transfering, response should write the content n times': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        transferPayload = {
                            status: 'transfer'
                            content: 'some content'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, transferPayload

                        resWriteSpy = sinon.spy testResponse, 'write'
                        req =
                            method: 'POST'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resWriteSpy.calledWith(transferPayload.content).should.be.true

                        callback.called.should.be.false

                        fileTransferStub.restore()
                        resWriteSpy.restore()

                    'when it completes, response should end with the content and callback with complete status': ->
                        fileTransferer = 
                            transfer: ->
                        callback = sinon.spy()
                        cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                        compelePayload = {
                            status: 'complete'
                            content: 'some content'
                        }

                        fileTransferStub = sinon
                            .stub(fileTransferer, 'transfer')
                            .callsArgWith 1, null, compelePayload

                        resEndSpy = sinon.spy testResponse, 'end'
                        req =
                            method: 'POST'
                            url: testUrl

                        cTransfer req, testResponse, callback

                        resEndSpy.calledWith(compelePayload.content).should.be.true

                        callback.calledOnce.should.be.true
                        args = callback.getCall(0).args
                        should.not.exist args[0]
                        args[1].should.have.property 'status', 'complete'

                        fileTransferStub.restore()
                        resEndSpy.restore()

            'for request of other methods':
                'it should not transfer file nor callback but only call next':->
                    fileTransferer = {
                        transfer: ->
                    }
                    callback = sinon.spy()
                    cTransfer = connectFileTransfer.transfer fileTransferer, testRoot, callback

                    fileTransferSpy = sinon
                        .spy(fileTransferer, 'transfer')

                    req =
                        method: 'other'
                        url: testUrl
                    
                    nextSpy = sinon.spy()
                    cTransfer req, testResponse, nextSpy

                    fileTransferSpy.called.should.be.false
                    callback.called.should.be.false
                    nextSpy.calledOnce.should.be.true

                    fileTransferSpy.restore()


    )
    .export module
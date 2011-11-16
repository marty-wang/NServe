vows = require 'vows'
should = require 'should'
sinon = require 'sinon'

connectFileTransfer = require '../lib/connect-file-transfer'

testRoot = "testRoot"
testUrl = "testUrl"
testError = new Error()
    
testResponse =
    writeHead: ->

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
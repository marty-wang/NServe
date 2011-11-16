vows = require 'vows'
should = require 'should'
sinon = require 'sinon'

fsUtil = require '../lib/fs-util'

fileTransfer = require '../lib/file-transfer'

testPath = 'testPath'
testData = 'test data'
testContentType = 'application/octet-stream'
testDataSize = testData.length
testFilePayload = 
    data: testData
    stats: size: testDataSize
testError = new Error()

vows.describe('file-transfer')
    .addBatch(
        'a file transferer created with a data transferer':
            topic: ->
                dataTransferer = {
                    transfer: (data, size, callback)->
                }
                fileTransferer = fileTransfer.create dataTransferer
                return {
                    fileTransferer: fileTransferer
                    dataTransferer: dataTransferer
                }
            '*transfer*':
                'if there is error, it should callback once with error and null payload': (topic)->
                    stub = sinon
                            .stub(fsUtil, 'readStatsAndFile')
                            .callsArgWith 1, testError, null
                    callback = sinon.spy()
                    topic.fileTransferer.transfer testPath, callback
                    
                    callback.callCount.should.eql 1
                    callback.calledWithExactly(testError, null).should.be.true
                    
                    stub.restore()
                                                    
                'if there is no error and it is the unlimited data transferer, it should callback twice with no error and payload': (topic)->
                    dataTransferer = topic.dataTransferer
                    fsStub = sinon
                        .stub(fsUtil, 'readStatsAndFile')
                        .callsArgWith 1, null, testFilePayload

                    transferStub = sinon
                        .stub(dataTransferer, 'transfer')
                        .callsArgWith 2, null, {
                            status: 'complete'
                            payload: testData
                        }

                    callback = sinon.spy()
                    topic.fileTransferer.transfer testPath, callback
                    
                    callback.callCount.should.eql 2
                    call0 = callback.getCall 0
                    call1 = callback.getCall 1

                    call0.calledWithExactly(null, {
                        status: 'start'
                        contentType: testContentType
                    }).should.be.true

                    call1.calledWithExactly(null, {
                        status: 'complete'
                        content: testData
                    }).should.be.true

                    fsStub.restore()                           
                    transferStub.restore()

                'if there is no error and it is the limited data transferer, it should callback n times with no error and payload': (topic)->
                    dataTransferer = topic.dataTransferer
                    fsStub = sinon
                        .stub(fsUtil, 'readStatsAndFile')
                        .callsArgWith 1, null, testFilePayload
                    
                    startData = 
                        status: 'start'
                        contentType: testContentType

                    transferData = 
                        status: 'transfer'
                        payload: 'transfer_chunk'
                    
                    completeData = 
                        status: 'complete'
                        payload: 'complete_chunk'

                    transferStub = sinon
                        .stub(dataTransferer, 'transfer', (data, size, cb) ->
                            cb null, transferData
                            cb null, completeData
                        )
                    
                    callback = sinon.spy()
                    topic.fileTransferer.transfer testPath, callback

                    callback.callCount.should.eql 3

                    call0 = callback.getCall 0
                    call0.calledWithExactly(null, startData).should.be.true

                    call1 = callback.getCall 1
                    call1.calledWithExactly(null, {
                        status: transferData.status
                        content: transferData.payload
                    }).should.be.true

                    call2 = callback.getCall 2
                    call2.calledWithExactly(null, {
                        status: completeData.status
                        content: completeData.payload
                    }).should.be.true

                    fsStub.restore()                           
                    transferStub.restore()
        
        'a file transferer created with a data transferer and some hooks':
            '*transfer*':
                'if there is no error, every hook should be called once in the same order as they are added': ->
                    dataTransferer = {
                        transfer: (data, size, callback)->
                    } 

                    hooks = []
                    for i in [1..3]
                        hooks.push sinon.spy()

                    fileTransferer = fileTransfer.create dataTransferer, hooks
    
                    fsStub = sinon
                        .stub(fsUtil, 'readStatsAndFile')
                        .callsArgWith 1, null, testFilePayload

                    fileTransferer.transfer testPath, sinon.spy()

                    preHook = null
                    for hook in hooks
                        hook.calledOnce.should.be.true
                        hook.calledWithExactly(testContentType, {
                            data: testData
                            size: testDataSize
                        }).should.be.true
                        if preHook?
                            hook.calledAfter(preHook).should.be.true
                        preHook = hook
                    
                    fsStub.restore()

                'if there is error, no hook should be called': ->
                    dataTransferer = {
                        transfer: (data, size, callback)->
                    } 

                    hooks = []
                    for i in [1..3]
                        hooks.push sinon.spy()

                    fileTransferer = fileTransfer.create dataTransferer, hooks
                    fsStub = sinon
                        .stub(fsUtil, 'readStatsAndFile')
                        .callsArgWith 1, testError, null

                    fileTransferer.transfer testPath, sinon.spy()

                    for hook in hooks
                        hook.called.should.be.false
                    
                    fsStub.restore()

    )
    .export module
            
    
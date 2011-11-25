sinon = require 'sinon'
should = require 'should'

fsUtil = require '../lib/fs-util'

fileTransfer = require '../lib/file-transfer'

describe 'file-transfer', ->
    describe '#transfer', ->
        testFilePath = "test file path"
        testError = new Error()
        testData = "test data"
        testDataSize = testData.length

        describe 'if it fails to read file', ->        
            it 'should call back with error and null data object', (done) ->
                fileTransferer = fileTransfer.create null
                readStatsAndFileStub = sinon
                    .stub(fsUtil, 'readStatsAndFile')
                    .callsArgWith(1, testError, null)
                
                fileTransferer.transfer testFilePath, (err, data) ->
                    done()
                    err.should.eql testError
                    should.not.exist data
                
                readStatsAndFileStub.restore()
            
        describe 'if it succeeds to read file', ->
            readStatsAndFileStub = null

            beforeEach ->
                readStatsAndFileStub = sinon
                    .stub(fsUtil, 'readStatsAndFile')
                    .callsArgWith(1, null, {
                        data: testData
                        stats:
                            size: testDataSize
                    })
            
            afterEach ->
                readStatsAndFileStub.restore()

            it 'should call back with "start" status before transfer', (done)->
                dataTransferer = 
                    transfer: ->
                
                fileTransferer = fileTransfer.create dataTransferer

                fileTransferer.transfer testFilePath, (err, data) ->
                    should.not.exist err
                    data.should.have.property 'status', 'start'
                    done();

            describe 'and if the file transferer have 0 hooks', ->
                it 'should call back with the data sent by data transfer', (done) ->
                    dataTransferer = 
                        transfer: (data, size, callback) ->
                            callback null, {
                                status: 'complete'
                                payload: testData
                            }
                            
                    callback = sinon.spy()
                    
                    fileTransferer = fileTransfer.create dataTransferer

                    fileTransferer.transfer testFilePath, (err, data) ->
                        callback err, data
                        if data.status is 'complete'
                            done()
                        
                            callback.callCount.should.eql 2

                            call1 = callback.getCall 1
                            call1.calledWith(null, {
                                status: 'complete'
                                content: testData
                            }).should.be.true                                    
        

fs = require 'fs'

vows = require 'vows'
should = require 'should'
sinon  = require 'sinon'

fileDeliver = require '../lib/file-deliver'

testPath = 'testFilePath'
testData = 'test data'
testDataSize = testData.length # 9 bytes
testStats = size: testDataSize
callbackData = 
    data: testData
    size: testDataSize
testError = new Error()

vows.describe('file deliver')
    .addBatch(
        'a file deliverer':
            topic: ->
                fileDeliver.create()

            '#deliver':
                'if no error, should callback once with no error and an object containing data and data size': (deliverer) ->
                    callback = sinon.spy()
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith 1, null, testStats
                    readFileStub = sinon
                        .stub(fs, 'readFile')
                        .callsArgWith 1, null, testData
                    
                    deliverer.deliver testPath, callback

                    callback.callCount.should.eql 1
                    callback.calledWithExactly(null, callbackData).should.be.true

                    statStub.restore()
                    readFileStub.restore()
                        
                'if stat error, should callback once with error and null data and should not read file': (deliverer) ->
                    callback = sinon.spy()
                    statStub = sinon
                        .stub(fs, 'stat')
                        .callsArgWith 1, testError, null
                    readFileStub = sinon
                        .stub(fs, 'readFile')
                    
                    deliverer.deliver testPath, callback

                    callback.callCount.should.eql 1
                    callback.calledWithExactly(testError, null).should.be.true
                    readFileStub.callCount.should.eql 0

                    statStub.restore()
                    readFileStub.restore()
    )
    .export module
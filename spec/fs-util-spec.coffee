fs = require 'fs'

vows = require 'vows'
should = require 'should'
sinon  = require 'sinon'

fsUtil = require '../lib/fs-util'

testPath = 'testFilePath'
testData = 'test data'
testDataSize = testData.length # 9 bytes
testStats = size: testDataSize
callbackData = 
    data: testData
    stats: testStats
testError = new Error()

vows.describe('fs-util')
    .addBatch(
        '#readStatsAndFile':
            'if no error, should callback once with no error and an object containing data and stats': ->
                callback = sinon.spy()
                statStub = sinon
                    .stub(fs, 'stat')
                    .callsArgWith 1, null, testStats
                readFileStub = sinon
                    .stub(fs, 'readFile')
                    .callsArgWith 1, null, testData
                
                fsUtil.readStatsAndFile testPath, callback

                callback.callCount.should.eql 1
                callback.calledWithExactly(null, callbackData).should.be.true

                statStub.restore()
                readFileStub.restore()
                    
            'if stat error, should callback once with error and null data': ->
                callback = sinon.spy()
                statStub = sinon
                    .stub(fs, 'stat')
                    .callsArgWith 1, testError, null
                readFileStub = sinon
                    .stub(fs, 'readFile')
                
                fsUtil.readStatsAndFile testPath, callback

                callback.callCount.should.eql 1
                callback.calledWithExactly(testError, null).should.be.true

                statStub.restore()
                readFileStub.restore()

            'if readfile error, should callback once with error and null data': ->
                callback = sinon.spy()
                statStub = sinon
                    .stub(fs, 'stat')
                    .callsArgWith 1, null, {}
                readFileStub = sinon
                    .stub(fs, 'readFile')
                    .callsArgWith 1, testError, null 
                
                fsUtil.readStatsAndFile testPath, callback

                callback.callCount.should.eql 1
                callback.calledWithExactly(testError, null).should.be.true

                statStub.restore()
                readFileStub.restore()

    )
    .export module
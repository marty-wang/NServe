fs = require 'fs'

should = require 'should'
sinon = require 'sinon'

fsUtil = require '../lib/fs-util'

describe 'fs-util', ->
    testFilePath = "testFilePath"
    testError = new Error()
    testStats = {}
    testData = "test data"

    describe '#readStatsAndFile', ->
        it 'should call back with error and null data if it fails to read the stats', (done) ->
            statStub = sinon
                .stub(fs, 'stat')
                .callsArgWith(1, testError, null)

            fsUtil.readStatsAndFile testFilePath, (err, data) ->
                done()
                err.should.eql testError
                should.not.exist data

            statStub.restore()

        it 'should call back with error and null data if it fails to read file', (done) ->
            statStub = sinon
                .stub(fs, 'stat')
                .callsArgWith(1, null, testStats)
            readFileStub = sinon
                .stub(fs, 'readFile')
                .callsArgWith(1, testError, null)

            fsUtil.readStatsAndFile testFilePath, (err, data) ->
                done()
                err.should.eql testError
                should.not.exist data

            statStub.restore()
            readFileStub.restore()

        it 'should call back with no error and data containing the stats object literal and data', (done) ->
            statStub = sinon
                .stub(fs, 'stat')
                .callsArgWith(1, null, testStats)
            readFileStub = sinon
                .stub(fs, 'readFile')
                .callsArgWith(1, null, testData)

            fsUtil.readStatsAndFile testFilePath, (err, data) ->
                done()
                should.not.exist err
                data.should.eql {
                    stats: testStats
                    data: testData
                }

            statStub.restore()
            readFileStub.restore()

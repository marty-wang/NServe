sinon = require 'sinon'
should = require 'should'

fsUtil = require '../lib/fs-util'

fileTransfer = require '../lib/file-transfer'

describe 'file-transfer', ->
    describe '#transfer', ->
        testFilePath = "/test/file/path"
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
            dataTransferer = null

            beforeEach ->
                readStatsAndFileStub = sinon
                    .stub(fsUtil, 'readStatsAndFile')
                    .callsArgWith(1, null, {
                        data: testData
                        stats:
                            size: testDataSize
                    })

                dataTransferer =
                    transfer: (data, size, callback) ->
                        callback null, {
                            status: 'complete'
                            payload: data
                        }

            afterEach ->
                readStatsAndFileStub.restore()

            it 'should call back with "start" status before transfer', (done)->
                callback = sinon.spy()

                fileTransferer = fileTransfer.create dataTransferer

                fileTransferer.transfer testFilePath, (err, data) ->
                    callback err, data

                    if data.status is 'complete'
                        done()

                        callback.callCount.should.eql 2

                        call0 = callback.getCall 0
                        should.not.exist call0.args[0]
                        call0.args[1].should.have.property 'status', 'start'


            describe 'and if the file transferer have 0 hooks', ->
                it 'should call back with the data sent by data transfer', (done) ->
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

            describe 'and if the file transferer have n hooks', ->
                it 'should call back with the data sent by data transfer but modified by the hooks', (done) ->
                    hooks = [
                        (contentType, dataObj) ->
                            dataObj.data += " hook1"
                            dataObj.size = testDataSize+6
                        (contentType, dataObj) ->
                            dataObj.data += " hook2"
                            dataObj.size = testDataSize+12
                    ]

                    callback = sinon.spy()
                    fileTransferer = fileTransfer.create dataTransferer, hooks

                    fileTransferer.transfer testFilePath, (err, data) ->
                        callback err, data
                        if data.status is 'complete'
                            done()

                            callback.callCount.should.eql 2

                            call1 = callback.getCall 1
                            call1.calledWith(null, {
                                status: 'complete'
                                content: testData + " hook1 hook2"
                            }).should.be.true

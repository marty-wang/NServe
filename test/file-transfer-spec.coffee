sinon = require 'sinon'
should = require 'should'

fsUtil = require '../lib/fs-util'
{EventEmitter} = require 'events'

fileTransfer = require '../lib/file-transfer'

describe 'file-transfer', ->
    describe '#transfer', ->
        testFilePath = "/test/file/path"
        testError = new Error()
        testData = "test data"
        testDataSize = testData.length

        describe 'if it fails to read file', ->
            it 'should emit "error" event', () ->
                fileTransferer = fileTransfer.create null
                readStatsAndFileStub = sinon
                    .stub(fsUtil, 'readStatsAndFile')
                    .callsArgWith(1, testError, null)

                fileTransferer.on 'error', (error) ->
                    error.should.eql testError

                fileTransferer.transfer testFilePath

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

                dataTransferer = new EventEmitter()
                dataTransferer.transfer = ->

            afterEach ->
                readStatsAndFileStub.restore()

            it 'should emit "start" event before transfer', ()->
                callback = sinon.spy()

                fileTransferer = fileTransfer.create dataTransferer

                fileTransferer.on 'start', ->
                    callback()

                fileTransferer.transfer testFilePath

                callback.calledOnce.should.be.true

            describe 'and if the file transferer have 0 hooks', ->
                it 'should emit "complete" event and/or "transfer" events with the data sent by data transfer', () ->
                    dataTransferStub = sinon.stub dataTransferer, 'transfer', (data, size) ->
                        @.emit 'transfer', 'test '
                        @.emit 'complete', 'data'
                    fileTransferer = fileTransfer.create dataTransferer
                    data = ''

                    fileTransferer.on 'transfer', (chunk) ->
                        data += chunk

                    fileTransferer.on 'complete', (chunk) ->
                        data += chunk

                    fileTransferer.transfer testFilePath

                    data.should.eql testData

                    dataTransferStub.restore()


            describe 'and if the file transferer have n hooks', ->
                it 'should send the data modified by the hooks', () ->
                    hooks = [
                        (contentType, dataObj) ->
                            dataObj.data += " hook1"
                            dataObj.size = testDataSize+6
                        (contentType, dataObj) ->
                            dataObj.data += " hook2"
                            dataObj.size = testDataSize+12
                    ]

                    dataTransferSpy = sinon.spy dataTransferer, 'transfer'
                    fileTransferer = fileTransfer.create dataTransferer, hooks

                    fileTransferer.transfer testFilePath

                    dataTransferSpy.calledWith('test data hook1 hook2').should.be.true

                    dataTransferSpy.restore()

should = require 'should'
vows = require 'vows'
sinon = require 'sinon'

dataTransfer = require '../lib/data-transfer'

testData = "This is a test!!!"
testDataSize = testData.length # 17 byts

vows.describe("data transfer")
    .addBatch(
        'initialized with 5 Bps':
            topic: ->
                dataTransfer.create '5'
            '#getRate':
                topic: (transferer) ->
                    transferer.getRate()
                'rate should equal to 5': (rate) ->
                    rate.should.eql '5'
            '#getBufferLength':
                topic: (tranferer) ->
                    tranferer.getBufferLength()
                'bufferLength should equal to 5': (bufferLength) ->
                    bufferLength.should.eql 5
            '#transfer':
                topic: (transferer) ->
                    clock = sinon.useFakeTimers()
                    ticks = Math.ceil(testDataSize/5) + 1
                    callback = sinon.spy()
                    transferer.transfer testData, testDataSize, callback
                    clock.tick(ticks*1000+100)
                    clock.restore()
                    callback
                "callback should be called 5 times with no error and data": (callback) ->
                    callback.callCount.should.eql 5
                    
                    call0 = callback.getCall 0
                    call0.calledWithExactly(null, {
                        status: 'transfer'
                        payload: 'This '
                    }).should.be.true                    
            
                    call1 = callback.getCall 1
                    call1.calledWithExactly(null, {
                        status: 'transfer'
                        payload: 'is a '
                    }).should.be.true                    

                    call2 = callback.getCall 2
                    call2.calledWithExactly(null, {
                        status: 'transfer'
                        payload: 'test!'
                    }).should.be.true                    

                    call3 = callback.getCall 3
                    call3.calledWithExactly(null, {
                        status: 'transfer'
                        payload: '!!'
                    }).should.be.true
                    
                    call4 = callback.getCall 4
                    call4.calledWithExactly(null, {
                        status: 'complete'
                        payload: null
                    }).should.be.true                    

        'initialized with 100K Bps':
            topic: ->
                dataTransfer.create '100K'
            '#getRate':
                topic: (transferer) ->
                    transferer.getRate()
                'rate should equal to 100K': (rate) ->
                    rate.should.eql '100K'
            '#getBufferLength':
                topic: (tranferer) ->
                    tranferer.getBufferLength()
                'bufferLength should equal to 100x1024': (bufferLength) ->
                    bufferLength.should.eql 100*1024
        
        'initialized with 5M':
            topic: ->
                dataTransfer.create '5M Bps'
            '#getRate':
                topic: (transferer) ->
                    transferer.getRate()
                'rate should equal to 5M': (rate) ->
                    rate.should.eql '5M'
            '#getBufferLength':
                topic: (tranferer) ->
                    tranferer.getBufferLength()
                'bufferLength should equal to 5x1024x1024': (bufferLength) ->
                    bufferLength.should.eql 5*1024*1024
        
        'initialized with nothing':
            topic: ->
                dataTransfer.create()
            '#getRate':
                topic: (transferer) ->
                    transferer.getRate()
                'rate should equal to unlimited': (rate) ->
                    rate.should.eql 'unlimited'
            '#getBufferLength':
                topic: (tranferer) ->
                    tranferer.getBufferLength()
                'bufferLength should equal to 0': (bufferLength) ->
                    bufferLength.should.eql 0
            '#transfer':
                topic: (transferer) ->
                    callback = sinon.spy()
                    transferer.transfer testData, testDataSize, callback
                    callback
                'callback should be called once with no error and data': (callback) ->
                    callback.callCount.should.eql 1
                    
                    call0 = callback.getCall 0
                    call0.calledWithExactly(null, {
                        status: 'complete'
                        payload: testData
                    }).should.be.true                   
                    
        'initialized with invalid value':
            topic: ->
                dataTransfer.create("invalid_value")
            '#getRate':
                topic: (transferer) ->
                    transferer.getRate()
                'rate should equal to unlimited': (rate) ->
                    rate.should.eql 'unlimited'
            '#getBufferLength':
                topic: (tranferer) ->
                    tranferer.getBufferLength()
                'bufferLength should equal to 0': (bufferLength) ->
                    bufferLength.should.eql 0         
    )
    .export module
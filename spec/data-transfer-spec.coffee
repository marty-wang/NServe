require 'should'
vows = require 'vows'

dataTransfer = require '../lib/1-data-transfer'

vows.describe("data transfer")
    .addBatch(
        'initialized with 100K':
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
                dataTransfer.create '5M'
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
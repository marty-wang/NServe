{EventEmitter} = require 'events'

rateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/

# Notes: the consumer of the class should decide if it should
# limit the minimal rate. However it is not Transferer's responsibility.

class Transferer extends EventEmitter

    constructor: (rate) ->
        @_rate = rate
        @_bufLen = null

        _parse.call @

    getActualRate: ->
        @_rate

    getBufferLength: ->
        @_bufLen

    transfer: (data, size) ->
        if @_bufLen <= 0
            @.emit 'complete', data
        else
            _transfer.call @, data, size, 0, @_bufLen

    ### Private ###
    _parse = ()->
        tr = rateRegEx.exec @_rate

        if tr?
            @_bufLen = tr[1]
            unit = tr[4].toUpperCase()
            @_rate = "#{@_bufLen}#{unit}"

            switch unit
                when 'K' then @_bufLen *= 1024
                when 'M' then @_bufLen *= 1024*1024

            @_bufLen = Math.round @_bufLen
        else
            @_rate = 'unlimited'
            @_bufLen = 0

    _transfer = (data, size, offset, bufLength) ->
        bufLength = Math.min bufLength, size-offset
        chunk = data.slice offset, offset+bufLength
        offset += chunk.length
        status = if offset >= size then 'complete' else 'transfer'
        @.emit status, chunk

        return if offset >= size

        setTimeout (=>
            _transfer.call @, data, size, offset, bufLength
        ), 1000

exports.create = (rate) ->
    new Transferer rate

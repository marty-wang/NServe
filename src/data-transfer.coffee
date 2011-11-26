rateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/

# Notes: the consumer of the class should decide if it should
# limit the minimal rate. However it is not Transferer's responsibility.

class Transferer

    constructor: (rate) ->
        @_rate = rate
        @_bufLen = null

        _parse.call @

    getActualRate: ->
        @_rate

    getBufferLength: ->
        @_bufLen

    transfer: (data, size, callback) ->
        if @_bufLen <= 0
            _callback callback, null, {
                status: 'complete'
                payload: data
            }
        else
            _transfer data, size, 0, @_bufLen, callback

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

    _transfer = (data, size, offset, bufLength, cb) ->
        bufLength = Math.min bufLength, size-offset
        chunk = data.slice offset, offset+bufLength
        offset += chunk.length
        status = if offset >= size then 'complete' else 'transfer'
        _callback cb, null, {
            status: status
            payload: chunk
        }
        return if offset >= size

        setTimeout (->
            _transfer data, size, offset, bufLength, cb
        ), 1000

    _callback = (callback, err, payload) ->
        process.nextTick(->
            callback err, payload
        ) if callback?

exports.create = (rate) ->
    new Transferer rate

DEFAULT_RATE = "500K" # 500k bps (bit per second)
DEFAULT_SPEAD = 512000

### Private ###

_speed = DEFAULT_SPEAD
_bufLen = Math.round _speed/8   # covert from bits to bytes
_rate = DEFAULT_RATE

_transfer = (data, size, offset, bufLength, fn) ->

    if offset >= size
        return fn.call null, {
            status: "complete"
        } if fn?
            
    bufLength = Math.min bufLength, size-offset
    chunk = data.slice offset, offset+bufLength
    offset += chunk.length
    fn.call null, {
        status: "transfer"
        payload: chunk
    } if fn?

    setTimeout (->
        _transfer data, size, offset, bufLength, fn
    ), 1000

### Public ###

transferRateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/g

parseRate = (transferRate) ->
    tr = transferRateRegEx.exec transferRate
    if tr?
        _speed = tr[1]
        unit = tr[4].toUpperCase()
        _rate = "#{_speed}#{unit}"

        switch unit
            when 'K' then _speed *= 1024
            when 'M' then _speed *= 1024*1024
        
        # TODO: set to default speed if the specified speed is too small
        _bufLen = Math.round _speed/8 # covert from bits to bytes
        _speed = Math.round _speed

getRate = ->
    _rate

# size is in byte, the transfer rate is in bps as bit per second
# 1 byte = 8 bits
transferData = (data, size, fn) ->
    _transfer data, size, 0, _bufLen, fn

exports.parseRate = parseRate
exports.getRate = getRate
exports.transferData = transferData
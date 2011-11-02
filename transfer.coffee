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

transferRateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/g

# size is in byte, the transfer rate is in bps as bit per second
# 1 byte = 8 bits
transferData = (data, size, fn, options = {}) ->
    speed = 512000 # 500k bps (bit per second)

    transferRate = options.transferRate
    tr = transferRateRegEx.exec transferRate
    if tr?
        speed = tr[1]
        unit = tr[4].toLowerCase()
        switch unit
            when 'k' then speed *= 1024
            when 'm' then speed *= 1024*1024
        speed = Math.round speed
    
    bufLen = Math.round speed/8 # covert from bits to bytes 

    _transfer data, size, 0, bufLen, fn

exports.transferData = transferData
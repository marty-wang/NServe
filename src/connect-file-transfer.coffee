fs = require "fs"
parse = require("url").parse

mime = require 'mime'

trans = require "./data-transfer"

### Private ###

_root = null
_rate = null
_fn = null

_callback = (status, payload) ->
    _fn.call null, {
        status: status
        payload: payload
    } if _fn?

_transfer = (req, res, next, fn) ->
    path = _root + parse(req.url).pathname

    try
        stat = fs.statSync path
        fs.readFile path, (err, data)->
            unless err?
                _callback "start", path
                
                contentType = mime.lookup path
                res.writeHead 200, {
                    'Content-Type': contentType
                }

                # if user specified the desired transfer rate
                if _rate?
                    trans.transferData data, stat.size, (result) ->
                        switch result.status
                            when "transfer"
                                res.write result.payload
                            when "complete"
                                res.end()
                                _callback "complete", path

                else # no transfer limit
                    res.end data
                    _callback "complete", path
            else
                throw err

    catch error
        _callback "error", path   
        next()

### Public ###

###
    if transferRate is null or undefined, it means unlimited
###
transfer = (transferRate, root, fn)->
    if transferRate?
        trans.parseRate transferRate
        _rate = trans.getRate()    

    _root = if root? then root else "."
    _fn = fn

    _callback "init", _rate
    
    (req, res, next) ->
        _transfer req, res, next, fn

exports.transfer = transfer
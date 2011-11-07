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
    pathname = parse(req.url).pathname
    path = _root + pathname

    try
        stat = fs.statSync path
        fs.readFile path, (err, data)->
            unless err?
                contentType = mime.lookup path
                _callback "start", {
                    request: req
                    path: pathname
                    content: data
                    contentType: contentType
                }

                size = stat.size

                if req.modifiedData?
                    data = req.modifiedData
                    size = req.modifiedDataSize

                res.writeHead 200, {
                    'Content-Type': contentType
                }

                # if user specified the desired transfer rate
                if _rate?
                    trans.transferData data, size, (result) ->
                        switch result.status
                            when "transfer"
                                res.write result.payload
                            when "complete"
                                res.end()
                                _callback "complete", pathname

                else # no transfer limit
                    res.end data
                    _callback "complete", pathname
            else
                throw err

    catch error
        _callback "error", pathname   
        next()

### Public ###

###
    if transferRate is null or undefined, it means unlimited
###
transfer = (transferRate, root, fn)->
    if transferRate?
        _rate = trans.parseRate transferRate

    _root = if root? then root else "."
    _fn = fn

    _callback "init", _rate
    
    (req, res, next) ->
        switch req.method.toUpperCase()
            when "GET", "POST"
                _transfer req, res, next, fn
            else
                next()

exports.transfer = transfer
fs = require "fs"
parse = require("url").parse

mime = require 'mime'
async = require 'async'

### Private ###

_transferer = null
_root = null
_callback = null

_update = (status, payload) ->
    _callback.call null, {
        status: status
        payload: payload
    } if _callback?

_transfer = (req, res, next) ->
    pathname = parse(req.url).pathname
    path = _root + pathname

    fileStats = null
    async.series {
        one: (go) ->
            fs.stat path, (err, stats) ->
                fileStats = stats          
                go err, stats
        two: (go) ->
            fs.readFile path, (err, data) ->
                if err?
                    go err, null
                else
                    contentType = mime.lookup path
                    _update "start", {
                        request: req
                        path: pathname
                        content: data
                        contentType: contentType
                    }

                    size = fileStats.size

                    if req.modifiedData?
                        data = req.modifiedData
                        size = req.modifiedDataSize

                    res.writeHead 200, {
                        'Content-Type': contentType
                    }

                    _transferer.transfer data, size, (err, result) ->
                        payload = result.payload
                        switch result.status
                            when "transfer"
                                res.write payload
                            when "complete"
                                res.end payload
                                _update "complete", pathname
            
                    go null, null
    },
    (err, results) ->
        if err?
            _update "error", pathname   
            next()

### Public ###

transfer = (transferer, root, callback)->
    _transferer = transferer
    _root = root
    _callback = callback
    
    (req, res, next) ->
        switch req.method.toUpperCase()
            when "GET", "POST"
                _transfer req, res, next
            else
                next()

exports.transfer = transfer
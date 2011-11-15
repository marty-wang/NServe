fs = require "fs"
parse = require("url").parse

### Private ###

_root = null
_callback = null
_fileTransferer = null

_cb = (error, payload) ->
    _callback error, payload if _callback?

_transfer = (req, res, next) ->
    pathname = parse(req.url).pathname
    filepath = _root + pathname

    _fileTransferer.transfer filepath, (err, payload) ->
        if err?
            _cb err, pathname
            next()
        else
            switch payload.status
                when 'start'
                    _cb null, {
                        status: 'start'
                        pathname: pathname
                    }
                    res.writeHead 200, {
                        'Content-Type': payload.contentType
                    }
                when 'transfer'
                    res.write payload.content
                when 'complete'
                    res.end payload.content
                    _cb null,  {
                        status: "complete"
                        pathname: pathname
                    }

### Public ###

transfer = (fileTransferer, root, callback) ->
    _root = root
    _callback = callback
    _fileTransferer = fileTransferer
    
    (req, res, next) ->
        switch req.method.toUpperCase()
            when "GET", "POST"
                _transfer req, res, next
            else
                next()

exports.transfer = transfer
fs = require "fs"
parse = require("url").parse

mime = require 'mime'
async = require 'async'

fileDeliver = require './file-deliver'

class FileTransferer

    constructor: (fileDeliverer, dataTransferer, hooks=[]) ->
        @_deliverer = fileDeliverer
        @_transferer = dataTransferer
        @_hooks = hooks

    transfer: (filepath, callback) ->
        @_deliverer.deliver filepath, (err, payload) =>
            if err?
                callback new Error(), null
            else
                data = payload.data
                size = payload.size
                contentType = mime.lookup filepath

                # hooks have the ability to change the data
                # before it gets transfered
                dataObj = 
                    data: data
                    size: size
                for hook in @_hooks
                    hook contentType, dataObj

                data = dataObj.data
                size = dataObj.size

                callback null, {
                    status: 'start'
                    contentType: contentType    
                }

                @_transferer.transfer data, size, (err, result) ->
                    chunk = result.payload
                    switch result.status
                        when "transfer"
                            callback null, {
                                status: 'transfer'
                                content: chunk
                            }
                        when "complete"
                            callback null, {
                                status: 'complete'
                                content: chunk
                            }

#------------------------------------------------------------------------------

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

transfer = (transferer, root, callback, hooks=[])->
    _root = root
    _callback = callback

    deliverer = fileDeliver.create()
    _fileTransferer = new FileTransferer deliverer, transferer, hooks
    
    (req, res, next) ->
        switch req.method.toUpperCase()
            when "GET", "POST"
                _transfer req, res, next
            else
                next()

exports.transfer = transfer
mime = require 'mime'

fsUtil = require './fs-util'

class FileTransferer

    # hooks have the ability to change the data
    # before it gets transfered
    constructor: (dataTransferer, hooks) ->
        @_transferer = dataTransferer
        @_hooks = hooks

    transfer: (filepath, callback) ->
        fsUtil.readStatsAndFile filepath, (err, payload) =>
            if err?
                _callback callback, err, null
            else
                data = payload.data
                size = payload.stats.size
                contentType = mime.lookup filepath

                dataObj =
                    data: data
                    size: size
                for hook in @_hooks
                    hook contentType, dataObj

                data = dataObj.data
                size = dataObj.size

                _callback callback, null, {
                    status: 'start'
                    contentType: contentType
                }

                @_transferer.transfer data, size, (err, result) ->
                    switch result.status
                        when "transfer"
                            _callback callback, null, {
                                status: 'transfer'
                                content: result.payload
                            }
                        when "complete"
                            _callback callback, null, {
                                status: 'complete'
                                content: result.payload
                            }

    _callback = (callback, err, data) ->
        process.nextTick(->
            callback err, data
        ) if callback?

exports.create = (dataTransferer, hooks=[]) ->
    new FileTransferer dataTransferer, hooks

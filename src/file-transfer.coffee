{EventEmitter} = require 'events'

mime = require 'mime'

fsUtil = require './fs-util'

class FileTransferer extends EventEmitter

    # hooks have the ability to change the data
    # before it gets transfered
    constructor: (dataTransferer, hooks) ->
        @_transferer = dataTransferer
        @_hooks = hooks

        return unless dataTransferer?

        dataTransferer.on 'transfer', (chunk) =>
            @.emit 'transfer', chunk

        dataTransferer.on 'complete', (chunk) =>
            @.emit 'complete', chunk

    transfer: (filepath, callback) ->
        fsUtil.readStatsAndFile filepath, (err, payload) =>
            if err?
                @.emit 'error', err
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

                @.emit 'start', contentType

                @_transferer.transfer data, size

exports.create = (dataTransferer, hooks=[]) ->
    new FileTransferer dataTransferer, hooks

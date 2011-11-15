fs = require 'fs'
async = require 'async'

class Deliverer

    deliver: (filepath, callback) ->
        async.series {
            stats: (go) ->
                fs.stat filepath, (err, stats) ->
                    go err, stats
            fileData: (go) ->
                fs.readFile filepath, (err, data) ->
                    go err, data
        },
        (err, results) ->
            if err?
                callback err, null
            else
                callback null, {
                    size: results.stats.size
                    data: results.fileData
                }
        
exports.create = (dataTransferer) ->
    new Deliverer()
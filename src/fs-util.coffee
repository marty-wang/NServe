fs = require 'fs'
async = require 'async'

exports.readStatsAndFile = (filepath, callback) ->
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
                stats: results.stats
                data: results.fileData
            }
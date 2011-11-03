fs = require "fs"
parse = require("url").parse

_transfer = (req, res) ->
    path = "." + parse(req.url).pathname
    console.log "transfer middleware gets through... for #{path}"

transfer = ->
    (req, res, next) ->
        _transfer req, res
        # dont have to next() if there is no error
        next()

exports.transfer = transfer
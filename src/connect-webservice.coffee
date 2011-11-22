parse = require("url").parse
fs = require 'fs'
path = require 'path'

_resHeader = {
    'Content-Type': "text/plain"
    'Access-Control-Allow-Origin': '*' # for cross-domain ajax
    'Access-Control-Allow-Headers': 'X-Requested-With'
}

class WebService

    constructor: (root, delay) ->
        @_root = root
        @_delay = delay

    respond: (req, res, errorFile) ->
        pathname = parse(req.url).pathname
        _respond.call @, req, res, pathname, errorFile

    _respond = (req, res, pathname, errorFile) ->
        setTimeout (=>
            unless errorFile?
                _readFile.call @, req, res, pathname, 200
            else
                pathname = path.resolve pathname, "../#{errorFile}"
                _readFile.call @, req, res, pathname, 404
        ), @_delay
        
    _readFile = (req, res, path, statusCode) ->
        fs.readFile @_root+path, (err, data) ->
            unless err?
                res.writeHead statusCode, _resHeader
                res.end data
            else
                res.writeHead 404, _resHeader
                retData = {
                    statusCode: 404
                    responseText: "Unexpected Error: #{req.method} #{path}"
                }
                res.end JSON.stringify retData

exports.create = (root, delay) ->
    new WebService root, delay
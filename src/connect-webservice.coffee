parse = require("url").parse
fs = require 'fs'
path = require 'path'

_root = null
_wsFolder = null
_delay = null

_isWS = (pathname) ->
    pathname is "/#{_wsFolder}" or pathname.indexOf("/#{_wsFolder}/") is 0

_resHeader = {
    'Content-Type': "text/plain"
    'Access-Control-Allow-Origin': '*' # for cross-domain ajax
    'Access-Control-Allow-Headers': 'X-Requested-With'
}

_readFile = (req, res, path, statusCode) ->
    fs.readFile _root+path, (err, data) ->
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

_respond = (req, res, pathname, errorFile) ->
    setTimeout (->
        unless errorFile?
            _readFile req, res, pathname, 200
        else
            pathname = path.resolve pathname, "../#{errorFile}"
            _readFile req, res, pathname, 404
    ), _delay

webservice = (root='.', webserviceFolder='ws', delay=0) ->
    _root = root
    _wsFolder = webserviceFolder
    _delay = delay

    (req, res, next) ->
        pathname = parse(req.url).pathname
        if _isWS pathname
            switch req.method.toUpperCase()
                when 'GET'
                    errorFile = req.query['error']
                    _respond req, res, pathname, errorFile                      
                when 'POST'
                    errorFile = req.body['error']
                    _respond req, res, pathname, errorFile                      
        else
            next()

exports.webservice = webservice
fs = require 'fs'
parse = require("url").parse
path = require "path"

mime = require 'mime'
cUtils = (require "connect").utils

# add file types that livepage should monitor
_types = [
    'text/html'
    'text/css'
    'application/javascript'
]

exports.connect = (root) ->
    (req, res, next) ->
        switch req.method.toUpperCase()
            when "HEAD"
                pathname = parse(req.url).pathname
                contentType = mime.lookup pathname
                if _types.indexOf(contentType) >= 0
                    filepath = path.join root, pathname
                    fs.stat filepath, (err, stats) ->
                        unless err?
                            res.writeHead 200, {
                                'Content-Type': contentType
                                'Etag': cUtils.etag(stats)
                            }
                        res.end()
                else
                    next()
            else
                next()

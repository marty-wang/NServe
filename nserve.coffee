DEFAULT_MIME = "text/plain"
VERSION_NUMBER = "0.0.2"

defaults =
    port: 3000

mimes = 
    ".htm": "text/html"
    ".html": "text/html"
    ".js": "text/javascript"
    ".css": "text/css"
    ".png": "image/png"
    ".jpg": "image/jpg"
    ".gif": "image/gif"

colors = require "colors"
sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse
program = require "commander"

transfer = require "./transfer"

### Private ###

_server = null

_parseCLI = ()->
    program
        .version(VERSION_NUMBER)
        .option('-p --port <n>', 'specify the port number', parseInt)
        .parse(process.argv)

    port = program.port
    defaults.port = port if port?

_init = ()->
    # a simple web server, serving out static files with the correct mime type
    http.createServer (req, res)->
        # work out which file is being requested
        path = parse(req.url).pathname
        # if the path ends in a forward slash
        if path.match /\/$/
            # assume index.html
            path += "index.html"
        # make path relative to "."
        path = "." + path

        try
            stat = fs.statSync path
            # load the file
            fs.readFile path, (err, data)->
                unless err
                    # exact file type
                    filetype = (path.match /\.[a-zA-Z]+$/)[0]
                    # work out the mime type
                    ct = _getMimeFrom filetype
                    
                    res.writeHead 200, {
                        'Content-Type': ct         
                    }

                    # for verbose mode
                    # console.log "[".grey + "start".green + "]".grey + " #{path}"
                    transfer.transferData data, stat.size, (result) ->
                        switch result.status
                            when "transfer"
                                res.write result.payload
                            when "complete"
                                console.log "[".grey + "served".yellow + "]".grey + " #{path}"
                                res.end()
                else
                    throw err

        catch error
            console.error "failed to get file at #{path}".red
            res.writeHead 404, {
                'Content-Type': DEFAULT_MIME
            }
            data = "File not found!\n"
            res.end(data);


_getMimeFrom = (filetype)->
    return DEFAULT_MIME unless filetype?

    mime = mimes[filetype]
    mime ?= DEFAULT_MIME
    mime

### bootstrap ###

_parseCLI()
_server = _init()

### Public ###

start = ->
    _server.listen defaults.port
    console.log "file server is running on ".green + "port ".cyan + "#{defaults.port}".underline.cyan

exports.start = start
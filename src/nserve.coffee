defaults =
    port: 3000

colors = require "colors"
sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse
program = require "commander"

transfer = require "./transfer"
mime = require "./mime"
versioning = require "./versioning"

### Private ###

_versionNumber = "x.x.x"
try
    _versionNumber = versioning.getVersionNumber()
catch error
    console.error error

_server = null

_parseCLI = ()->
    program
        .version(_versionNumber)
        .option('-p --port <n>', 'specify the port number', parseInt)
        .option('-r --rate <bit rate>', 'specify the file transfer rate, e.g. 100k or 5m')
        .parse(process.argv)

    port = program.port
    defaults.port = port if port?
    defaults.rate = program.rate

_init = ()->
    http.createServer (req, res)->
        path = parse(req.url).pathname
        # if the path ends in a forward slash
        # assume index.html
        if path.match /\/$/
            path += "index.html"
        # make path relative to "."
        path = "." + path

        try
            stat = fs.statSync path
            fs.readFile path, (err, data)->
                unless err
                    filetype = (path.match /\.[a-zA-Z]+$/)[0]
                    contentType = mime.contentType filetype

                    res.writeHead 200, {
                        'Content-Type': contentType
                    }

                    # if user specified the desired transfer rate
                    if defaults.rate?
                        # console.log "[".grey + "start".green + "]".grey + " #{path}"
                        transfer.transferData data, stat.size, ((result) ->
                            switch result.status
                                when "transfer"
                                    res.write result.payload
                                when "complete"
                                    res.end()
                                    console.log "[".grey + "served".yellow + "]".grey + " #{path}"
                            ), {
                                transferRate: defaults.rate
                            }

                    else # no transfer limit
                        res.end data
                        console.log "[".grey + "served".yellow + "]".grey + " #{path}"
                else
                    throw err

        catch error
            res.writeHead 404, {
                'Content-Type': mime.contentType ".txt"
            }
            data = "File not found!\n"
            res.end data
            console.error "failed to get file at #{path}".red

### bootstrap ###

_parseCLI()
_server = _init()

### Public ###

start = ->
    _server.listen defaults.port
    console.log "file server is running on ".green + "port ".cyan + "#{defaults.port}".underline.cyan

exports.start = start
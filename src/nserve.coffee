DEFAULT_PORT = 3000

colors = require "colors"
sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse
program = require "commander"

transfer = require "./transfer"
mime = require "./mime"
versioning = require "./versioning"
time = require './time'

### Private ###

_server = null
_versionNumber = "x.x.x"
# options
_isVerbose = false
_port = DEFAULT_PORT
_rate = null

_version = ->
    try
        _versionNumber = versioning.getVersionNumber()
    catch error
        console.error error

_parseCLI = ()->
    program
        .version(_versionNumber)
        .option('-p, --port <n>', 'specify the port number', parseInt)
        .option('-r, --rate <bit rate>', 'specify the file transfer rate, e.g. 100k or 5m')
        .option('-v, --verbose', 'enter verbose mode')
        .parse(process.argv)

    port = program.port
    _port = port if port? and not isNaN(port)
    _rate = program.rate
    _isVerbose = !!program.verbose

_now = ->
    if _isVerbose then " @ #{time.now()}" else ""

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

                    if _isVerbose
                        console.log "[".grey + "started#{_now()}".yellow + "]".grey + " #{path}"

                    # if user specified the desired transfer rate
                    if _rate?
                        transfer.transferData data, stat.size, ((result) ->
                            switch result.status
                                when "transfer"
                                    res.write result.payload
                                when "complete"
                                    res.end()
                                    console.log "[".grey + "served#{_now()}".green + "]".grey + " #{path}"
                            ), {
                                transferRate: _rate
                            }

                    else # no transfer limit
                        res.end data
                        console.log "[".grey + "served#{_now()}".green + "]".grey + " #{path}"
                else
                    throw err

        catch error
            res.writeHead 404, {
                'Content-Type': mime.contentType ".txt"
            }
            data = "File not found!\n"
            res.end data
            console.error "[".grey + "failed#{_now()}".red + "]".grey + " #{path}"

### bootstrap ###

_version()
_parseCLI()
_server = _init()

### Public ###

start = ->
    _server.listen _port

    console.log "------------------------------------------"
    console.log "file server is running...".green
    console.log "   port ".cyan + "#{_port}"
    console.log "   rate ".cyan + if _rate? then "#{_rate}" else "unlimited"
    console.log "   mode ".cyan + "Verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
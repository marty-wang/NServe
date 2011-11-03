DEFAULT_PORT = 3000

colors = require "colors"
sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse

connect = require "connect"
program = require "commander"

transfer = require "./transfer"
mime = require "./mime"
versioning = require "./versioning"
time = require './time'
fileTransfer = (require "./connect-file-transfer").transfer

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
    _isVerbose = !!program.verbose

    if program.rate?
        transfer.parseRate program.rate
        _rate = transfer.getRate()

_now = ->
    if _isVerbose then " @ #{time.now()}" else ""

_init_connect = () ->
    connect.createServer(
        _router(),
        fileTransfer()
    )

_router = ->
    connect.router (app) ->            

        ### Routing ###

        app.get '/', (req, res, next) ->
            req.url += "index.html"
            next();

        app.get '/index.html', (req, res, next) ->
            res.end "this is index.html"
        
        ### Web service ###

        app.get '/ws/:file', (req, res, next) ->
            res.writeHead 200, {
                'Content-Type': "text/plain"
                'Access-Control-Allow-Origin': '*' # for cross-domain ajax
            }
            res.end req.params.file
        
        app.post '/ws', (req, res, next) ->
            res.writeHead 200, {
                'Content-Type': "text/plain"
                'Access-Control-Allow-Origin': '*' # for cross-domain ajax
            }
            res.end "post success"

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
                        'Access-Control-Allow-Origin': '*' # for cross-domain ajax
                    }

                    if _isVerbose
                        console.log "[".grey + "started#{_now()}".yellow + "]".grey + " #{path}"

                    # if user specified the desired transfer rate
                    if _rate?
                        transfer.transferData data, stat.size, (result) ->
                            switch result.status
                                when "transfer"
                                    res.write result.payload
                                when "complete"
                                    res.end()
                                    console.log "[".grey + "served#{_now()}".green + "]".grey + " #{path}"

                    else # no transfer limit
                        res.end data
                        console.log "[".grey + "served#{_now()}".green + "]".grey + " #{path}"
                else
                    throw err

        catch error
            res.writeHead 404, {
                'Content-Type': mime.contentType ".txt"
                'Access-Control-Allow-Origin': '*'
            }
            data = "File not found!\n"
            res.end data
            console.error "[".grey + "failed#{_now()}".red + "]".grey + " #{path}"

### bootstrap ###

_version()
_parseCLI()
_server = _init_connect()

### Public ###

start = ->
    _server.listen _port

    console.log "------------------------------------------"
    console.log "file server is running...".green
    console.log "   port ".cyan + "#{_port}"
    console.log "   rate ".cyan + if _rate? then "#{_rate} (bps)" else "unlimited"
    console.log "   mode ".cyan + "verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
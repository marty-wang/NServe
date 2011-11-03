DEFAULT_PORT = 3000

sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse

connect = require "connect"
program = require "commander"
colors = require "colors"

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

    _rate = program.rate

_now = ->
    if _isVerbose then " @ #{time.now()}" else ""

_fileTransferCallback  = (data) ->
    switch data.status
        when "init"
            _rate = data.payload
        when "start"
            if _isVerbose
                console.log "[".grey + "started#{_now()}".yellow + "]".grey + " #{data.payload}"
        when "complete"
            console.log "[".grey + "served#{_now()}".green + "]".grey + " #{data.payload}"
        when "error"
            console.error "[".grey + "failed#{_now()}".red + "]".grey + " #{data.payload}"

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

_init = () ->
    connect.createServer(
        connect.favicon(),
        _router(),
        connect.directory(process.cwd()),
        fileTransfer(_rate, _fileTransferCallback)
    )

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
    console.log "   rate ".cyan + if _rate? then "#{_rate} (bps)" else "unlimited"
    console.log "   mode ".cyan + "verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
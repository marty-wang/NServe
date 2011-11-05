DEFAULT_PORT = 3000
DEFAULT_WEBSERVICE_FOLDER = "ws"
DEFAULT_WEBSERVICE_DELAY = 0

sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse
path = require "path"

connect = require "connect"
program = require "commander"
colors = require "colors"

fileTransfer = (require "./connect-file-transfer").transfer
webservice = (require "./connect-webservice").webservice
util = require "./util"

### Private ###

_server = null
_versionNumber = "x.x.x"
# options
_isVerbose = false
_port = DEFAULT_PORT
_rate = null
_root = null
_webserviceFolder = null
_webserviceDelay = 0

_version = ->
    try
        _versionNumber = util.getVersionNumber()
    catch error
        console.error error

_parseCLI = ()->
    program
        .version(_versionNumber)
        .option('-p, --port <n>', 'specify the port number [3000]', parseInt)
        .option('-r, --rate <bit rate>', 'specify the file transfer rate in Bps, e.g. 100K or 5M')
        .option('-v, --verbose', 'enter verbose mode')
        .option('-d, --directory <root>', 'specify the root directory, either relative or absolute [current directory]')
        .option('-w, --webservice-folder <folder name>', 'specify the webservice folder name ["ws"]')
        .option('-D, --webservice-delay <n>', 'specify the delay of the web service in millisecond [0]', parseInt)
        .parse(process.argv)

    port = program.port
    _port = port if port? and not isNaN(port)
    _isVerbose = !!program.verbose
    _rate = program.rate

    root = util.absoluteDirPath program.directory
    _root = if root? then root else process.cwd()

    wsFolder = program.webserviceFolder
    _webserviceFolder = if wsFolder? then util.normalizeFolderName(wsFolder) else DEFAULT_WEBSERVICE_FOLDER

    wsDelay = program.webserviceDelay
    _webserviceDelay = if wsDelay? and not isNaN(wsDelay) then wsDelay else DEFAULT_WEBSERVICE_DELAY

_now = ->
    if _isVerbose then " @ #{util.now()}" else ""

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

        app.get '/', (req, res, next) ->
            req.url += "index.html"
            next();
        
_init = () ->
    connect.createServer(
        connect.bodyParser(),
        connect.query(),
        _router(),
        webservice(_root, _webserviceFolder, _webserviceDelay),
        connect.favicon(),
        connect.directory(_root),
        fileTransfer(_rate, _root, _fileTransferCallback)
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
    console.log "   root ".cyan + "#{_root}"
    console.log "   port ".cyan + "#{_port}"
    console.log "   rate ".cyan + if _rate? then "#{_rate}(Bps)" else "unlimited"
    console.log "   webservice folder ".cyan + "#{_webserviceFolder}"
    console.log "   webservice delay ".cyan + "#{_webserviceDelay} ms"
    console.log "   mode ".cyan + "verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
DEFAULT_PORT = 3000
DEFAULT_ROOT = '.'
DEFAULT_RATE = 'unlimited'
DEFAULT_WEBSERVICE_FOLDER = "ws"
DEFAULT_WEBSERVICE_DELAY = 0

sys = require "sys"
fs = require "fs"
http = require "http"
parse = require("url").parse
path = require "path"

connect = require "connect"
colors = require "colors"

ncli = require './nserve-cli'
fileTransfer = (require "./connect-file-transfer").transfer
webservice = (require "./connect-webservice").webservice
livepage = require './connect-livepage'
util = require "./util"

### Private ###

_server = null
_versionNumber = "x.x.x"
_root = null
# options
_isVerbose = false
_port = DEFAULT_PORT
_rate = null
_webserviceFolder = null
_webserviceDelay = 0
_isLiveReload = false
  
_version = ->
    try
        _versionNumber = util.getVersionNumber()
    catch error
        console.error error

_parseCLI = ()->
    argv = ncli.defaults(
        port: DEFAULT_PORT
        root: DEFAULT_ROOT
        rate: DEFAULT_RATE
        webserviceFolder: DEFAULT_WEBSERVICE_FOLDER
        webserviceDelay: DEFAULT_WEBSERVICE_DELAY
        version: _versionNumber
    )
    .argv()

    _port = argv.port
    _isVerbose = argv.verbose
    _rate = argv.rate

    _webserviceFolder = argv.webserviceFolder
    _webserviceDelay = argv.webserviceDelay
    _isLiveReload = argv.liveReload

    root = util.absoluteDirPath argv.root
    _root = if root? then root else process.cwd()

_now = ->
    if _isVerbose then " @ #{util.now()}" else ""

_fileTransferCallback  = (data) ->
    switch data.status
        when "init"
            _rate = data.payload
        when "start"
            payload = data.payload
            if _isLiveReload
                contentType = payload.contentType
                if contentType is "text/html"
                    # insert live script here
                    req = payload.request
                    content = payload.content
                    content = livepage.insertLiveScript content, contentType
                    req.modifiedData = content
                    req.modifiedDataSize = content.length

            if _isVerbose
                console.log "[".grey + "started#{_now()}".yellow + "]".grey + " {root}".grey + "#{payload.path}"
        when "complete"
            console.log "[".grey + "served#{_now()}".green + "]".grey + " {root}".grey + "#{data.payload}"
        when "error"
            console.error "[".grey + "failed#{_now()}".red + "]".grey + " {root}".grey + "#{data.payload}"

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
        livepage.live(_root, _isLiveReload),
        webservice(_root, _webserviceFolder, _webserviceDelay),
        connect.favicon(path.resolve __dirname, "../public/favicon.ico"),
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
    console.log "   livereload: ".cyan + "#{_isLiveReload}"
    console.log "   webservice folder ".cyan + "#{_webserviceFolder}"
    console.log "   webservice delay ".cyan + "#{_webserviceDelay} ms"
    console.log "   mode ".cyan + "verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
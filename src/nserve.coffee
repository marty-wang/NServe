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
dataTransfer = require './data-transfer'
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

_fileTransferCallback  = (error, data) ->
    if error?
        return console.error "[".grey + "failed#{_now()}".red + "]".grey + " {root}".grey + "#{data}"
    
    switch data.status
        when "start"
            if _isVerbose
                console.log "[".grey + "started#{_now()}".yellow + "]".grey + " {root}".grey + "#{data.pathname}"
        when "complete"
            console.log "[".grey + "served#{_now()}".green + "]".grey + " {root}".grey + "#{data.pathname}"            

_router = ->
    connect.router (app) ->            

        app.get '/', (req, res, next) ->
            req.url += "index.html"
            next();
        
_init = () ->
    _server = connect()

    transferer = dataTransfer.create _rate
    _rate = transferer.getActualRate()

    hooks = []

    _server.use connect.favicon(path.resolve __dirname, "../public/favicon.ico")
    _server.use connect.bodyParser()
    _server.use connect.query()
    _server.use _router()

    if _isLiveReload
        _server.use livepage.live(_root)
        hooks.push (contentType, dataObj) ->
            if contentType is "text/html"
                # insert live script here
                content = livepage.insertLiveScript dataObj.data, contentType
                dataObj.data = content
                dataObj.size = content.length

    _server.use webservice(_root, _webserviceFolder, _webserviceDelay)
    _server.use connect.directory(_root)
    _server.use fileTransfer(transferer, _root, _fileTransferCallback, hooks)

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
    console.log "   rate ".cyan + "#{_rate} (Bps)"
    console.log "   livereload: ".cyan + "#{_isLiveReload}"
    console.log "   webservice folder ".cyan + "#{_webserviceFolder}"
    console.log "   webservice delay ".cyan + "#{_webserviceDelay} ms"
    console.log "   mode ".cyan + "verbose" if _isVerbose
    console.log "------------------------------------------"

exports.start = start
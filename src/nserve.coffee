DEFAULT_PORT = 3000
DEFAULT_ROOT = '.'
DEFAULT_RATE = 'unlimited'
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
fileTransfer = require './file-transfer'
connectFileTransfer = (require "./connect-file-transfer").transfer
webservice = require "./connect-webservice"
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
    argv = ncli.parse process.argv, {
        port: DEFAULT_PORT
        root: DEFAULT_ROOT
        rate: DEFAULT_RATE
        webserviceDelay: DEFAULT_WEBSERVICE_DELAY
        version: _versionNumber
    }

    _isVerbose = argv.option 'verbose'
    _rate = argv.option 'rate'
    _isLiveReload = argv.option 'liveReload'

    _port = argv.option 'port'
    if isNaN(_port)
        throw "port must be an integer value"

    root = util.absoluteDirPath argv.root()
    _root = if root? then root else process.cwd()

    _webserviceFolder = argv.option 'webserviceFolder'
    _webserviceDelay = argv.option 'webserviceDelay'
    if isNaN(_webserviceDelay)
        throw "webservice delay must be an integer value"

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

        if _webserviceFolder?
            webservice = webservice.create _root, _webserviceDelay

            app.get "/#{_webserviceFolder}/:file", (req, res, next) ->
                errorFile = req.query['error']
                webservice.respond req, res, errorFile

            app.post "/#{_webserviceFolder}/:file", (req, res, next) ->
                errorFile = req.body['error']
                webservice.respond req, res, errorFile
        
_init = () ->
    _server = connect()
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

    _server.use connect.directory(_root)

    dataTransferer = dataTransfer.create _rate
    _rate = dataTransferer.getActualRate()

    fileTransferer = fileTransfer.create dataTransferer, hooks
    _server.use connectFileTransfer(fileTransferer, _root, _fileTransferCallback)

    _server


### bootstrap ###

_version()
_parseCLI()
_server = _init()

### Public ###

start = ->
    _server.listen _port

    console.log "------------------------------------------"
    console.log "file server is running...".green
    console.log "   root: ".cyan + "#{_root}"
    console.log "   port: ".cyan + "#{_port}"
    console.log "   rate: ".cyan + "#{_rate} (Bps)"
    if _webserviceFolder?
        console.log "   webservice folder: ".cyan + "#{_webserviceFolder}"
        console.log "   webservice delay: ".cyan + "#{_webserviceDelay} ms"
    else
        console.log "   webservice: ".cyan + "false"
    console.log "   livereload: ".cyan + "#{_isLiveReload}"
    console.log "   verbose: ".cyan + "#{_isVerbose}"
    console.log "------------------------------------------"

exports.start = start
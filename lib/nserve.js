(function() {
  var DEFAULT_PORT, DEFAULT_WEBSERVICE_DELAY, DEFAULT_WEBSERVICE_FOLDER, colors, connect, fileTransfer, fs, http, parse, path, program, start, sys, util, webservice, _fileTransferCallback, _init, _isVerbose, _now, _parseCLI, _port, _rate, _root, _router, _server, _version, _versionNumber, _webserviceDelay, _webserviceFolder;
  DEFAULT_PORT = 3000;
  DEFAULT_WEBSERVICE_FOLDER = "ws";
  DEFAULT_WEBSERVICE_DELAY = 0;
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  path = require("path");
  connect = require("connect");
  program = require("commander");
  colors = require("colors");
  fileTransfer = (require("./connect-file-transfer")).transfer;
  webservice = (require("./connect-webservice")).webservice;
  util = require("./util");
  /* Private */
  _server = null;
  _versionNumber = "x.x.x";
  _isVerbose = false;
  _port = DEFAULT_PORT;
  _rate = null;
  _root = null;
  _webserviceFolder = null;
  _webserviceDelay = 0;
  _version = function() {
    try {
      return _versionNumber = util.getVersionNumber();
    } catch (error) {
      return console.error(error);
    }
  };
  _parseCLI = function() {
    var port, root, wsDelay, wsFolder;
    program.version(_versionNumber).option('-p, --port <n>', 'specify the port number [3000]', parseInt).option('-r, --rate <bit rate>', 'specify the file transfer rate in Bps, e.g. 100K or 5M').option('-v, --verbose', 'enter verbose mode').option('-d, --directory <root>', 'specify the root directory, either relative or absolute [current directory]').option('-w, --webservice-folder <folder name>', 'specify the webservice folder name ["ws"]').option('-D, --webservice-delay <n>', 'specify the delay of the web service in millisecond [0]', parseInt).parse(process.argv);
    port = program.port;
    if ((port != null) && !isNaN(port)) {
      _port = port;
    }
    _isVerbose = !!program.verbose;
    _rate = program.rate;
    root = util.absoluteDirPath(program.directory);
    _root = root != null ? root : process.cwd();
    wsFolder = program.webserviceFolder;
    _webserviceFolder = wsFolder != null ? util.normalizeFolderName(wsFolder) : DEFAULT_WEBSERVICE_FOLDER;
    wsDelay = program.webserviceDelay;
    return _webserviceDelay = (wsDelay != null) && !isNaN(wsDelay) ? wsDelay : DEFAULT_WEBSERVICE_DELAY;
  };
  _now = function() {
    if (_isVerbose) {
      return " @ " + (util.now());
    } else {
      return "";
    }
  };
  _fileTransferCallback = function(data) {
    switch (data.status) {
      case "init":
        return _rate = data.payload;
      case "start":
        if (_isVerbose) {
          return console.log("[".grey + ("started" + (_now())).yellow + "]".grey + (" " + data.payload));
        }
        break;
      case "complete":
        return console.log("[".grey + ("served" + (_now())).green + "]".grey + (" " + data.payload));
      case "error":
        return console.error("[".grey + ("failed" + (_now())).red + "]".grey + (" " + data.payload));
    }
  };
  _router = function() {
    return connect.router(function(app) {
      return app.get('/', function(req, res, next) {
        req.url += "index.html";
        return next();
      });
    });
  };
  _init = function() {
    return connect.createServer(connect.bodyParser(), connect.query(), _router(), webservice(_root, _webserviceFolder, _webserviceDelay), connect.favicon(), connect.directory(_root), fileTransfer(_rate, _root, _fileTransferCallback));
  };
  /* bootstrap */
  _version();
  _parseCLI();
  _server = _init();
  /* Public */
  start = function() {
    _server.listen(_port);
    console.log("------------------------------------------");
    console.log("file server is running...".green);
    console.log("   root ".cyan + ("" + _root));
    console.log("   port ".cyan + ("" + _port));
    console.log("   rate ".cyan + (_rate != null ? "" + _rate + "(Bps)" : "unlimited"));
    console.log("   webservice folder ".cyan + ("" + _webserviceFolder));
    console.log("   webservice delay ".cyan + ("" + _webserviceDelay + " ms"));
    if (_isVerbose) {
      console.log("   mode ".cyan + "verbose");
    }
    return console.log("------------------------------------------");
  };
  exports.start = start;
}).call(this);

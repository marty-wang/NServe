(function() {
  var DEFAULT_PORT, colors, connect, fileTransfer, fs, http, parse, program, start, sys, util, webservice, _fileTransferCallback, _init, _isVerbose, _now, _parseCLI, _port, _rate, _root, _router, _server, _version, _versionNumber;
  DEFAULT_PORT = 3000;
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
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
  _version = function() {
    try {
      return _versionNumber = util.getVersionNumber();
    } catch (error) {
      return console.error(error);
    }
  };
  _parseCLI = function() {
    var port, root;
    program.version(_versionNumber).option('-p, --port <n>', 'specify the port number [3000]', parseInt).option('-r, --rate <bit rate>', 'specify the file transfer rate, e.g. 100k or 5m').option('-v, --verbose', 'enter verbose mode').option('-d, --directory <root>', 'specify the root directory, either relative or absolute [current directory]').parse(process.argv);
    port = program.port;
    if ((port != null) && !isNaN(port)) {
      _port = port;
    }
    _isVerbose = !!program.verbose;
    _rate = program.rate;
    root = util.absoluteDirPath(program.directory);
    return _root = root != null ? root : process.cwd();
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
    return connect.createServer(connect.bodyParser(), _router(), webservice(), connect.favicon(), connect.directory(_root), fileTransfer(_rate, _root, _fileTransferCallback));
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
    console.log("   rate ".cyan + (_rate != null ? "" + _rate + " (bps)" : "unlimited"));
    if (_isVerbose) {
      console.log("   mode ".cyan + "verbose");
    }
    return console.log("------------------------------------------");
  };
  exports.start = start;
}).call(this);

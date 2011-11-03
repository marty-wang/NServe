(function() {
  var DEFAULT_PORT, colors, connect, fileTransfer, fs, http, parse, program, start, sys, util, _fileTransferCallback, _init, _isVerbose, _now, _parseCLI, _port, _rate, _root, _router, _server, _version, _versionNumber;
  DEFAULT_PORT = 3000;
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  connect = require("connect");
  program = require("commander");
  colors = require("colors");
  fileTransfer = (require("./connect-file-transfer")).transfer;
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
      /* Routing */      app.get('/', function(req, res, next) {
        req.url += "index.html";
        return next();
      });
      /* Web service */
      app.get('/ws/:file', function(req, res, next) {
        res.writeHead(200, {
          'Content-Type': "text/plain",
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'X-Requested-With'
        });
        return res.end(req.params.file);
      });
      return app.post('/ws', function(req, res, next) {
        res.writeHead(200, {
          'Content-Type': "text/plain",
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'X-Requested-With'
        });
        return res.end("post result");
      });
    });
  };
  _init = function() {
    return connect.createServer(_router(), connect.favicon(), connect.directory(_root), fileTransfer(_rate, _root, _fileTransferCallback));
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

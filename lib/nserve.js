(function() {
  var DEFAULT_PORT, colors, connect, fileTransfer, fs, http, parse, program, start, sys, time, versioning, _fileTransferCallback, _init, _isVerbose, _now, _parseCLI, _port, _rate, _router, _server, _version, _versionNumber;
  DEFAULT_PORT = 3000;
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  connect = require("connect");
  program = require("commander");
  colors = require("colors");
  versioning = require("./versioning");
  time = require('./time');
  fileTransfer = (require("./connect-file-transfer")).transfer;
  /* Private */
  _server = null;
  _versionNumber = "x.x.x";
  _isVerbose = false;
  _port = DEFAULT_PORT;
  _rate = null;
  _version = function() {
    try {
      return _versionNumber = versioning.getVersionNumber();
    } catch (error) {
      return console.error(error);
    }
  };
  _parseCLI = function() {
    var port;
    program.version(_versionNumber).option('-p, --port <n>', 'specify the port number', parseInt).option('-r, --rate <bit rate>', 'specify the file transfer rate, e.g. 100k or 5m').option('-v, --verbose', 'enter verbose mode').parse(process.argv);
    port = program.port;
    if ((port != null) && !isNaN(port)) {
      _port = port;
    }
    _isVerbose = !!program.verbose;
    return _rate = program.rate;
  };
  _now = function() {
    if (_isVerbose) {
      return " @ " + (time.now());
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
    return connect.createServer(_router(), connect.favicon(), connect.directory(process.cwd()), fileTransfer(_rate, _fileTransferCallback));
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
    console.log("   port ".cyan + ("" + _port));
    console.log("   rate ".cyan + (_rate != null ? "" + _rate + " (bps)" : "unlimited"));
    if (_isVerbose) {
      console.log("   mode ".cyan + "verbose");
    }
    return console.log("------------------------------------------");
  };
  exports.start = start;
}).call(this);

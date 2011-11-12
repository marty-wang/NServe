(function() {
  var DEFAULT_PORT, DEFAULT_RATE, DEFAULT_ROOT, DEFAULT_WEBSERVICE_DELAY, DEFAULT_WEBSERVICE_FOLDER, colors, connect, fileTransfer, fs, http, livepage, ncli, parse, path, start, sys, util, webservice, _fileTransferCallback, _init, _isLiveReload, _isVerbose, _now, _parseCLI, _port, _rate, _root, _router, _server, _version, _versionNumber, _webserviceDelay, _webserviceFolder;
  DEFAULT_PORT = 3000;
  DEFAULT_ROOT = '.';
  DEFAULT_RATE = 'unlimited';
  DEFAULT_WEBSERVICE_FOLDER = "ws";
  DEFAULT_WEBSERVICE_DELAY = 0;
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  path = require("path");
  connect = require("connect");
  colors = require("colors");
  ncli = require('./nserve-cli');
  fileTransfer = (require("./connect-file-transfer")).transfer;
  webservice = (require("./connect-webservice")).webservice;
  livepage = require('./connect-livepage');
  util = require("./util");
  /* Private */
  _server = null;
  _versionNumber = "x.x.x";
  _root = null;
  _isVerbose = false;
  _port = DEFAULT_PORT;
  _rate = null;
  _webserviceFolder = null;
  _webserviceDelay = 0;
  _isLiveReload = false;
  _version = function() {
    try {
      return _versionNumber = util.getVersionNumber();
    } catch (error) {
      return console.error(error);
    }
  };
  _parseCLI = function() {
    var argv, root;
    argv = ncli.defaults({
      port: DEFAULT_PORT,
      root: DEFAULT_ROOT,
      rate: DEFAULT_RATE,
      webserviceFolder: DEFAULT_WEBSERVICE_FOLDER,
      webserviceDelay: DEFAULT_WEBSERVICE_DELAY,
      version: _versionNumber
    }).argv();
    _port = argv.port;
    _isVerbose = argv.verbose;
    _rate = argv.rate;
    _webserviceFolder = argv.webserviceFolder;
    _webserviceDelay = argv.webserviceDelay;
    _isLiveReload = argv.liveReload;
    root = util.absoluteDirPath(argv.root);
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
    var content, contentType, payload, req;
    switch (data.status) {
      case "init":
        return _rate = data.payload;
      case "start":
        payload = data.payload;
        if (_isLiveReload) {
          contentType = payload.contentType;
          if (contentType === "text/html") {
            req = payload.request;
            content = payload.content;
            content = livepage.insertLiveScript(content, contentType);
            req.modifiedData = content;
            req.modifiedDataSize = content.length;
          }
        }
        if (_isVerbose) {
          return console.log("[".grey + ("started" + (_now())).yellow + "]".grey + " {root}".grey + ("" + payload.path));
        }
        break;
      case "complete":
        return console.log("[".grey + ("served" + (_now())).green + "]".grey + " {root}".grey + ("" + data.payload));
      case "error":
        return console.error("[".grey + ("failed" + (_now())).red + "]".grey + " {root}".grey + ("" + data.payload));
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
    return connect.createServer(connect.bodyParser(), connect.query(), _router(), livepage.live(_root, _isLiveReload), webservice(_root, _webserviceFolder, _webserviceDelay), connect.favicon(path.resolve(__dirname, "../public/favicon.ico")), connect.directory(_root), fileTransfer(_rate, _root, _fileTransferCallback));
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
    console.log("   livereload: ".cyan + ("" + _isLiveReload));
    console.log("   webservice folder ".cyan + ("" + _webserviceFolder));
    console.log("   webservice delay ".cyan + ("" + _webserviceDelay + " ms"));
    if (_isVerbose) {
      console.log("   mode ".cyan + "verbose");
    }
    return console.log("------------------------------------------");
  };
  exports.start = start;
}).call(this);

(function() {
  var DEFAULT_PORT, DEFAULT_RATE, DEFAULT_ROOT, DEFAULT_WEBSERVICE_DELAY, colors, connect, connectFileTransfer, dataTransfer, fileTransfer, fs, http, livepage, ncli, parse, path, start, sys, util, webservice, _fileTransferCallback, _init, _isLiveReload, _isVerbose, _now, _parseCLI, _port, _rate, _root, _router, _server, _version, _versionNumber, _webserviceDelay, _webserviceFolder;

  DEFAULT_PORT = 3000;

  DEFAULT_ROOT = '.';

  DEFAULT_RATE = 'unlimited';

  DEFAULT_WEBSERVICE_DELAY = 0;

  sys = require("sys");

  fs = require("fs");

  http = require("http");

  parse = require("url").parse;

  path = require("path");

  connect = require("connect");

  colors = require("colors");

  ncli = require('./nserve-cli');

  dataTransfer = require('./data-transfer');

  fileTransfer = require('./file-transfer');

  connectFileTransfer = (require("./connect-file-transfer")).transfer;

  webservice = (require("./connect-webservice")).webservice;

  livepage = require('./connect-livepage');

  util = require("./util");

  /* Private
  */

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
    argv = ncli.parse(process.argv, {
      port: DEFAULT_PORT,
      root: DEFAULT_ROOT,
      rate: DEFAULT_RATE,
      webserviceDelay: DEFAULT_WEBSERVICE_DELAY,
      version: _versionNumber
    });
    _isVerbose = argv.option('verbose');
    _rate = argv.option('rate');
    _isLiveReload = argv.option('liveReload');
    _port = argv.option('port');
    if (isNaN(_port)) throw "port must be an integer value";
    root = util.absoluteDirPath(argv.root());
    _root = root != null ? root : process.cwd();
    _webserviceFolder = argv.option('webserviceFolder');
    _webserviceDelay = argv.option('webserviceDelay');
    if (isNaN(_webserviceDelay)) throw "webservice delay must be an integer value";
  };

  _now = function() {
    if (_isVerbose) {
      return " @ " + (util.now());
    } else {
      return "";
    }
  };

  _fileTransferCallback = function(error, data) {
    if (error != null) {
      return console.error("[".grey + ("failed" + (_now())).red + "]".grey + " {root}".grey + ("" + data));
    }
    switch (data.status) {
      case "start":
        if (_isVerbose) {
          return console.log("[".grey + ("started" + (_now())).yellow + "]".grey + " {root}".grey + ("" + data.pathname));
        }
        break;
      case "complete":
        return console.log("[".grey + ("served" + (_now())).green + "]".grey + " {root}".grey + ("" + data.pathname));
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
    var dataTransferer, fileTransferer, hooks;
    _server = connect();
    hooks = [];
    _server.use(connect.favicon(path.resolve(__dirname, "../public/favicon.ico")));
    _server.use(connect.bodyParser());
    _server.use(connect.query());
    _server.use(_router());
    if (_isLiveReload) {
      _server.use(livepage.live(_root));
      hooks.push(function(contentType, dataObj) {
        var content;
        if (contentType === "text/html") {
          content = livepage.insertLiveScript(dataObj.data, contentType);
          dataObj.data = content;
          return dataObj.size = content.length;
        }
      });
    }
    _server.use(connect.directory(_root));
    if (_webserviceFolder != null) {
      _server.use(webservice(_root, _webserviceFolder, _webserviceDelay));
    }
    dataTransferer = dataTransfer.create(_rate);
    _rate = dataTransferer.getActualRate();
    fileTransferer = fileTransfer.create(dataTransferer, hooks);
    _server.use(connectFileTransfer(fileTransferer, _root, _fileTransferCallback));
    return _server;
  };

  /* bootstrap
  */

  _version();

  _parseCLI();

  _server = _init();

  /* Public
  */

  start = function() {
    _server.listen(_port);
    console.log("------------------------------------------");
    console.log("file server is running...".green);
    console.log("   root: ".cyan + ("" + _root));
    console.log("   port: ".cyan + ("" + _port));
    console.log("   rate: ".cyan + ("" + _rate + " (Bps)"));
    if (_webserviceFolder != null) {
      console.log("   web service folder: ".cyan + ("" + _webserviceFolder));
      console.log("   web service delay: ".cyan + ("" + _webserviceDelay + " ms"));
    } else {
      console.log("   web service: ".cyan + "false");
    }
    console.log("   livereload: ".cyan + ("" + _isLiveReload));
    console.log("   verbose: ".cyan + ("" + _isVerbose));
    return console.log("------------------------------------------");
  };

  exports.start = start;

}).call(this);

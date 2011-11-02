(function() {
  var DEFAULT_PORT, colors, fs, http, mime, parse, program, start, sys, time, transfer, versioning, _init, _isVerbose, _now, _parseCLI, _port, _rate, _server, _version, _versionNumber;
  DEFAULT_PORT = 3000;
  colors = require("colors");
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  program = require("commander");
  transfer = require("./transfer");
  mime = require("./mime");
  versioning = require("./versioning");
  time = require('./time');
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
    if (program.rate != null) {
      transfer.parseRate(program.rate);
      return _rate = transfer.getRate();
    }
  };
  _now = function() {
    if (_isVerbose) {
      return " @ " + (time.now());
    } else {
      return "";
    }
  };
  _init = function() {
    return http.createServer(function(req, res) {
      var data, path, stat;
      path = parse(req.url).pathname;
      if (path.match(/\/$/)) {
        path += "index.html";
      }
      path = "." + path;
      try {
        stat = fs.statSync(path);
        return fs.readFile(path, function(err, data) {
          var contentType, filetype;
          if (!err) {
            filetype = (path.match(/\.[a-zA-Z]+$/))[0];
            contentType = mime.contentType(filetype);
            res.writeHead(200, {
              'Content-Type': contentType,
              'Access-Control-Allow-Origin': '*'
            });
            if (_isVerbose) {
              console.log("[".grey + ("started" + (_now())).yellow + "]".grey + (" " + path));
            }
            if (_rate != null) {
              return transfer.transferData(data, stat.size, function(result) {
                switch (result.status) {
                  case "transfer":
                    return res.write(result.payload);
                  case "complete":
                    res.end();
                    return console.log("[".grey + ("served" + (_now())).green + "]".grey + (" " + path));
                }
              });
            } else {
              res.end(data);
              return console.log("[".grey + ("served" + (_now())).green + "]".grey + (" " + path));
            }
          } else {
            throw err;
          }
        });
      } catch (error) {
        res.writeHead(404, {
          'Content-Type': mime.contentType(".txt"),
          'Access-Control-Allow-Origin': '*'
        });
        data = "File not found!\n";
        res.end(data);
        return console.error("[".grey + ("failed" + (_now())).red + "]".grey + (" " + path));
      }
    });
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

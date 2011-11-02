(function() {
  var DEFAULT_MIME, VERSION_NUMBER, colors, defaults, fs, http, mimes, parse, program, start, sys, transfer, _getMimeFrom, _init, _parseCLI, _server;
  DEFAULT_MIME = "text/plain";
  VERSION_NUMBER = "0.0.2";
  defaults = {
    port: 3000
  };
  mimes = {
    ".htm": "text/html",
    ".html": "text/html",
    ".js": "text/javascript",
    ".css": "text/css",
    ".png": "image/png",
    ".jpg": "image/jpg",
    ".gif": "image/gif"
  };
  colors = require("colors");
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  program = require("commander");
  transfer = require("./transfer");
  /* Private */
  _server = null;
  _parseCLI = function() {
    var port;
    program.version(VERSION_NUMBER).option('-p --port <n>', 'specify the port number', parseInt).parse(process.argv);
    port = program.port;
    if (port != null) {
      return defaults.port = port;
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
          var ct, filetype;
          if (!err) {
            filetype = (path.match(/\.[a-zA-Z]+$/))[0];
            ct = _getMimeFrom(filetype);
            res.writeHead(200, {
              'Content-Type': ct
            });
            return transfer.transferData(data, stat.size, function(result) {
              switch (result.status) {
                case "transfer":
                  return res.write(result.payload);
                case "complete":
                  console.log("[".grey + "served".yellow + "]".grey + (" " + path));
                  return res.end();
              }
            });
          } else {
            throw err;
          }
        });
      } catch (error) {
        console.error(("failed to get file at " + path).red);
        res.writeHead(404, {
          'Content-Type': DEFAULT_MIME
        });
        data = "File not found!\n";
        return res.end(data);
      }
    });
  };
  _getMimeFrom = function(filetype) {
    var mime;
    if (filetype == null) {
      return DEFAULT_MIME;
    }
    mime = mimes[filetype];
    if (mime == null) {
      mime = DEFAULT_MIME;
    }
    return mime;
  };
  /* bootstrap */
  _parseCLI();
  _server = _init();
  /* Public */
  start = function() {
    _server.listen(defaults.port);
    return console.log("file server is running on ".green + "port ".cyan + ("" + defaults.port).underline.cyan);
  };
  exports.start = start;
}).call(this);

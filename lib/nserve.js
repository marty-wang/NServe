(function() {
  var colors, defaults, fs, http, mime, parse, program, start, sys, transfer, versioning, _init, _parseCLI, _server, _versionNumber;
  defaults = {
    port: 3000
  };
  colors = require("colors");
  sys = require("sys");
  fs = require("fs");
  http = require("http");
  parse = require("url").parse;
  program = require("commander");
  transfer = require("./transfer");
  mime = require("./mime");
  versioning = require("./versioning");
  /* Private */
  _versionNumber = "x.x.x";
  try {
    _versionNumber = versioning.getVersionNumber();
  } catch (error) {
    console.error(error);
  }
  _server = null;
  _parseCLI = function() {
    var port;
    program.version(_versionNumber).option('-p --port <n>', 'specify the port number', parseInt).option('-r --rate <bit rate>', 'specify the file transfer rate, e.g. 100k or 5m').parse(process.argv);
    port = program.port;
    if (port != null) {
      defaults.port = port;
    }
    return defaults.rate = program.rate;
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
              'Content-Type': contentType
            });
            if (defaults.rate != null) {
              return transfer.transferData(data, stat.size, (function(result) {
                switch (result.status) {
                  case "transfer":
                    return res.write(result.payload);
                  case "complete":
                    res.end();
                    return console.log("[".grey + "served".yellow + "]".grey + (" " + path));
                }
              }), {
                transferRate: defaults.rate
              });
            } else {
              res.end(data);
              return console.log("[".grey + "served".yellow + "]".grey + (" " + path));
            }
          } else {
            throw err;
          }
        });
      } catch (error) {
        res.writeHead(404, {
          'Content-Type': mime.contentType(".txt")
        });
        data = "File not found!\n";
        res.end(data);
        return console.error(("failed to get file at " + path).red);
      }
    });
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

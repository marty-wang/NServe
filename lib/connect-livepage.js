(function() {
  var cUtils, fs, mime, parse, path, _types;

  fs = require('fs');

  parse = require("url").parse;

  path = require("path");

  mime = require('mime');

  cUtils = (require("connect")).utils;

  _types = ['text/html', 'text/css', 'application/javascript'];

  exports.connect = function(root) {
    return function(req, res, next) {
      var contentType, filepath, pathname;
      switch (req.method.toUpperCase()) {
        case "HEAD":
          pathname = parse(req.url).pathname;
          contentType = mime.lookup(pathname);
          if (_types.indexOf(contentType) >= 0) {
            filepath = path.join(root, pathname);
            return fs.stat(filepath, function(err, stats) {
              if (err == null) {
                res.writeHead(200, {
                  'Content-Type': contentType,
                  'Etag': cUtils.etag(stats)
                });
              }
              return res.end();
            });
          } else {
            return next();
          }
          break;
        default:
          return next();
      }
    };
  };

}).call(this);

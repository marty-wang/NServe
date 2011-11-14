(function() {
  var async, fs, mime, parse, transfer, _callback, _root, _transfer, _transferer, _update;
  fs = require("fs");
  parse = require("url").parse;
  mime = require('mime');
  async = require('async');
  /* Private */
  _transferer = null;
  _root = null;
  _callback = null;
  _update = function(status, payload) {
    if (_callback != null) {
      return _callback.call(null, {
        status: status,
        payload: payload
      });
    }
  };
  _transfer = function(req, res, next) {
    var fileStats, path, pathname;
    pathname = parse(req.url).pathname;
    path = _root + pathname;
    fileStats = null;
    return async.series({
      one: function(go) {
        return fs.stat(path, function(err, stats) {
          fileStats = stats;
          return go(err, stats);
        });
      },
      two: function(go) {
        return fs.readFile(path, function(err, data) {
          var contentType, size;
          if (err != null) {
            return go(err, null);
          } else {
            contentType = mime.lookup(path);
            _update("start", {
              request: req,
              path: pathname,
              content: data,
              contentType: contentType
            });
            size = fileStats.size;
            if (req.modifiedData != null) {
              data = req.modifiedData;
              size = req.modifiedDataSize;
            }
            res.writeHead(200, {
              'Content-Type': contentType
            });
            _transferer.transfer(data, size, function(err, result) {
              var payload;
              payload = result.payload;
              switch (result.status) {
                case "transfer":
                  return res.write(payload);
                case "complete":
                  res.end(payload);
                  return _update("complete", pathname);
              }
            });
            return go(null, null);
          }
        });
      }
    }, function(err, results) {
      if (err != null) {
        _update("error", pathname);
        return next();
      }
    });
  };
  /* Public */
  transfer = function(transferer, root, callback) {
    _transferer = transferer;
    _root = root;
    _callback = callback;
    return function(req, res, next) {
      switch (req.method.toUpperCase()) {
        case "GET":
        case "POST":
          return _transfer(req, res, next);
        default:
          return next();
      }
    };
  };
  exports.transfer = transfer;
}).call(this);

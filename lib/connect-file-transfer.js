(function() {
  var async, fs, mime, parse, trans, transfer, _callback, _fn, _rate, _root, _transfer;
  fs = require("fs");
  parse = require("url").parse;
  mime = require('mime');
  async = require('async');
  trans = require("./data-transfer");
  /* Private */
  _root = null;
  _rate = null;
  _fn = null;
  _callback = function(status, payload) {
    if (_fn != null) {
      return _fn.call(null, {
        status: status,
        payload: payload
      });
    }
  };
  _transfer = function(req, res, next, fn) {
    var fileStats, path, pathname;
    pathname = parse(req.url).pathname;
    path = _root + pathname;
    fileStats = null;
    return async.series({
      one: function(callback) {
        return fs.stat(path, function(err, stats) {
          fileStats = stats;
          return callback(err, stats);
        });
      },
      two: function(callback) {
        return fs.readFile(path, function(err, data) {
          var contentType, size;
          if (err != null) {
            return callback(err, null);
          } else {
            contentType = mime.lookup(path);
            _callback("start", {
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
            if (_rate != null) {
              trans.transferData(data, size, function(result) {
                switch (result.status) {
                  case "transfer":
                    return res.write(result.payload);
                  case "complete":
                    res.end();
                    return _callback("complete", pathname);
                }
              });
            } else {
              res.end(data);
              _callback("complete", pathname);
            }
            return callback(null, null);
          }
        });
      }
    }, function(err, results) {
      if (err != null) {
        _callback("error", pathname);
        return next();
      }
    });
  };
  /* Public */
  /*
      if transferRate is null or undefined, it means unlimited
  */
  transfer = function(transferRate, root, fn) {
    if (transferRate != null) {
      _rate = trans.parseRate(transferRate);
    }
    _root = root != null ? root : ".";
    _fn = fn;
    _callback("init", _rate);
    return function(req, res, next) {
      switch (req.method.toUpperCase()) {
        case "GET":
        case "POST":
          return _transfer(req, res, next, fn);
        default:
          return next();
      }
    };
  };
  exports.transfer = transfer;
}).call(this);

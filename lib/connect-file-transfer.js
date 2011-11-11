(function() {
  var Futures, ffs, fs, mime, parse, trans, transfer, _callback, _fn, _rate, _root, _transfer;
  fs = require("fs");
  parse = require("url").parse;
  mime = require('mime');
  Futures = require('futures');
  ffs = require('futures-fs');
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
    var path, pathname;
    pathname = parse(req.url).pathname;
    path = _root + pathname;
    return Futures.sequence().then(function(go) {
      return ffs.stat(path).when(function(err, stats) {
        if (err != null) {
          _callback("error", pathname);
          return next();
        } else {
          return go(stats);
        }
      });
    }).then(function(go, stats) {
      return ffs.readFile(path).when(function(err, data) {
        var contentType, size;
        if (err != null) {
          _callback("error", pathname);
          return next();
        } else {
          contentType = mime.lookup(path);
          _callback("start", {
            request: req,
            path: pathname,
            content: data,
            contentType: contentType
          });
          size = stats.size;
          if (req.modifiedData != null) {
            data = req.modifiedData;
            size = req.modifiedDataSize;
          }
          res.writeHead(200, {
            'Content-Type': contentType
          });
          if (_rate != null) {
            return trans.transferData(data, size, function(result) {
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
            return _callback("complete", pathname);
          }
        }
      });
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

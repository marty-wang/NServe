(function() {
  var fs, parse, path, transfer, _callback, _cb, _fileTransferer, _root, _transfer;

  fs = require("fs");

  parse = require("url").parse;

  path = require('path');

  /* Private
  */

  _root = null;

  _callback = null;

  _fileTransferer = null;

  _cb = function(error, payload) {
    if (_callback != null) {
      return process.nextTick(function() {
        return _callback(error, payload);
      });
    }
  };

  _transfer = function(req, res, next) {
    var filepath, pathname;
    pathname = parse(req.url).pathname;
    filepath = path.join(_root, pathname);
    return _fileTransferer.transfer(filepath, function(err, payload) {
      if (err != null) {
        _cb(err, pathname);
        return next();
      } else {
        switch (payload.status) {
          case 'start':
            _cb(null, {
              status: 'start',
              pathname: pathname
            });
            return res.writeHead(200, {
              'Content-Type': payload.contentType
            });
          case 'transfer':
            return res.write(payload.content);
          case 'complete':
            res.end(payload.content);
            return _cb(null, {
              status: "complete",
              pathname: pathname
            });
        }
      }
    });
  };

  /* Public
  */

  transfer = function(fileTransferer, root, callback) {
    _root = root;
    _callback = callback;
    _fileTransferer = fileTransferer;
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

(function() {
  var FileTransferer, fs, fsUtil, mime, parse, transfer, _callback, _cb, _fileTransferer, _root, _transfer;

  fs = require("fs");

  parse = require("url").parse;

  mime = require('mime');

  fsUtil = require('./fs-util');

  FileTransferer = (function() {

    function FileTransferer(dataTransferer, hooks) {
      if (hooks == null) hooks = [];
      this._transferer = dataTransferer;
      this._hooks = hooks;
    }

    FileTransferer.prototype.transfer = function(filepath, callback) {
      var _this = this;
      return fsUtil.readStatsAndFile(filepath, function(err, payload) {
        var contentType, data, dataObj, hook, size, _i, _len, _ref;
        if (err != null) {
          return callback(new Error(), null);
        } else {
          data = payload.data;
          size = payload.stats.size;
          contentType = mime.lookup(filepath);
          dataObj = {
            data: data,
            size: size
          };
          _ref = _this._hooks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            hook = _ref[_i];
            hook(contentType, dataObj);
          }
          data = dataObj.data;
          size = dataObj.size;
          callback(null, {
            status: 'start',
            contentType: contentType
          });
          return _this._transferer.transfer(data, size, function(err, result) {
            var chunk;
            chunk = result.payload;
            switch (result.status) {
              case "transfer":
                return callback(null, {
                  status: 'transfer',
                  content: chunk
                });
              case "complete":
                return callback(null, {
                  status: 'complete',
                  content: chunk
                });
            }
          });
        }
      });
    };

    return FileTransferer;

  })();

  /* Private
  */

  _root = null;

  _callback = null;

  _fileTransferer = null;

  _cb = function(error, payload) {
    if (_callback != null) return _callback(error, payload);
  };

  _transfer = function(req, res, next) {
    var filepath, pathname;
    pathname = parse(req.url).pathname;
    filepath = _root + pathname;
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

  transfer = function(dataTransferer, root, callback, hooks) {
    if (hooks == null) hooks = [];
    _root = root;
    _callback = callback;
    _fileTransferer = new FileTransferer(dataTransferer, hooks);
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

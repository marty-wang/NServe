(function() {
  var fs, mime, parse, trans, transfer, _callback, _fn, _rate, _root, _transfer;
  fs = require("fs");
  parse = require("url").parse;
  mime = require('mime');
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
    var path, stat;
    path = _root + parse(req.url).pathname;
    try {
      stat = fs.statSync(path);
      return fs.readFile(path, function(err, data) {
        var contentType;
        if (err == null) {
          _callback("start", path);
          contentType = mime.lookup(path);
          res.writeHead(200, {
            'Content-Type': contentType
          });
          if (_rate != null) {
            return trans.transferData(data, stat.size, function(result) {
              switch (result.status) {
                case "transfer":
                  return res.write(result.payload);
                case "complete":
                  res.end();
                  return _callback("complete", path);
              }
            });
          } else {
            res.end(data);
            return _callback("complete", path);
          }
        } else {
          throw err;
        }
      });
    } catch (error) {
      _callback("error", path);
      return next();
    }
  };
  /* Public */
  /*
      if transferRate is null or undefined, it means unlimited
  */
  transfer = function(transferRate, root, fn) {
    if (transferRate != null) {
      trans.parseRate(transferRate);
      _rate = trans.getRate();
    }
    _root = root != null ? root : ".";
    _fn = fn;
    _callback("init", _rate);
    return function(req, res, next) {
      return _transfer(req, res, next, fn);
    };
  };
  exports.transfer = transfer;
}).call(this);

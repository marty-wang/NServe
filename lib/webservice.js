(function() {
  var WebService, fs, parse, path, _resHeader;

  parse = require("url").parse;

  fs = require('fs');

  path = require('path');

  _resHeader = {
    'Content-Type': "text/plain",
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'X-Requested-With'
  };

  WebService = (function() {
    var _readFile, _respond;

    function WebService(root, delay) {
      this._root = root;
      this._delay = delay;
    }

    WebService.prototype.respond = function(req, res, errorFile) {
      var pathname;
      pathname = parse(req.url).pathname;
      return _respond.call(this, req, res, pathname, errorFile);
    };

    _respond = function(req, res, pathname, errorFile) {
      var _this = this;
      return setTimeout((function() {
        if (errorFile == null) {
          return _readFile.call(_this, req, res, pathname, 200);
        } else {
          pathname = path.resolve(pathname, "../" + errorFile);
          return _readFile.call(_this, req, res, pathname, 404);
        }
      }), this._delay);
    };

    _readFile = function(req, res, pathname, statusCode) {
      var filePath;
      filePath = path.join(this._root, pathname);
      return fs.readFile(filePath, function(err, data) {
        var retData;
        if (err == null) {
          res.writeHead(statusCode, _resHeader);
          return res.end(data);
        } else {
          res.writeHead(404, _resHeader);
          retData = {
            statusCode: 404,
            responseText: "Unexpected Error: " + req.method + " " + pathname
          };
          return res.end(JSON.stringify(retData));
        }
      });
    };

    return WebService;

  })();

  exports.create = function(root, delay) {
    return new WebService(root, delay);
  };

}).call(this);

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

    _readFile = function(req, res, path, statusCode) {
      return fs.readFile(this._root + path, function(err, data) {
        var retData;
        if (err == null) {
          res.writeHead(statusCode, _resHeader);
          return res.end(data);
        } else {
          res.writeHead(404, _resHeader);
          retData = {
            statusCode: 404,
            responseText: "Unexpected Error: " + req.method + " " + path
          };
          return res.end(JSON.stringify(retData));
        }
      });
    };

    return WebService;

  })();

  exports.webservice = function(root, wsFolder, delay) {
    var pattern, regEx, ws;
    pattern = "^/" + wsFolder + "/";
    regEx = new RegExp(pattern);
    ws = new WebService(root, delay);
    return function(req, res, next) {
      var errorFile, url;
      url = req.url;
      if (regEx.test(url)) {
        switch (req.method) {
          case 'GET':
            errorFile = req.query['error'];
            return ws.respond(req, res, errorFile);
          case 'POST':
            errorFile = req.body['error'];
            return ws.respond(req, res, errorFile);
          default:
            return next();
        }
      } else {
        return next();
      }
    };
  };

}).call(this);

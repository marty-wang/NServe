(function() {
  var fs, parse, path, webservice, _isWS, _readFile, _resHeader, _respond, _root, _timeout, _wsFolder;
  parse = require("url").parse;
  fs = require('fs');
  path = require('path');
  _root = null;
  _wsFolder = null;
  _timeout = null;
  _isWS = function(pathname) {
    return pathname === ("/" + _wsFolder) || pathname.indexOf("/" + _wsFolder + "/") === 0;
  };
  _resHeader = {
    'Content-Type': "text/plain",
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'X-Requested-With'
  };
  _readFile = function(req, res, path, statusCode) {
    return fs.readFile(_root + path, function(err, data) {
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
  _respond = function(req, res, pathname, errorFile) {
    return setTimeout((function() {
      if (errorFile == null) {
        return _readFile(req, res, pathname, 200);
      } else {
        pathname = path.resolve(pathname, "../" + errorFile);
        return _readFile(req, res, pathname, 404);
      }
    }), _timeout);
  };
  webservice = function(root, webserviceFolder, timeout) {
    if (root == null) {
      root = '.';
    }
    if (webserviceFolder == null) {
      webserviceFolder = 'ws';
    }
    if (timeout == null) {
      timeout = 0;
    }
    _root = root;
    _wsFolder = webserviceFolder;
    _timeout = timeout;
    return function(req, res, next) {
      var errorFile, pathname;
      pathname = parse(req.url).pathname;
      if (_isWS(pathname)) {
        switch (req.method.toUpperCase()) {
          case 'GET':
            errorFile = req.query['error'];
            return _respond(req, res, pathname, errorFile);
          case 'POST':
            errorFile = req.body['error'];
            return _respond(req, res, pathname, errorFile);
        }
      } else {
        return next();
      }
    };
  };
  exports.webservice = webservice;
}).call(this);

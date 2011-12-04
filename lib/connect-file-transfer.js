(function() {
  var fs, parse, path;

  fs = require("fs");

  parse = require("url").parse;

  path = require('path');

  exports.connect = function(fileTransferer, root, callback) {
    var asyncCallback, nextFn, pathname, req, res;
    req = null;
    res = null;
    nextFn = null;
    pathname = null;
    asyncCallback = function(error, payload) {
      if (callback != null) {
        return process.nextTick(function() {
          return callback(error, payload);
        });
      }
    };
    fileTransferer.on('error', function(error) {
      asyncCallback(error, pathname);
      return nextFn();
    });
    fileTransferer.on('start', function(data) {
      res.writeHead(200, {
        'Content-Type': data
      });
      return asyncCallback(null, {
        status: 'start',
        pathname: pathname
      });
    });
    fileTransferer.on('transfer', function(data) {
      return res.write(data);
    });
    fileTransferer.on('complete', function(data) {
      res.end(data);
      return asyncCallback(null, {
        status: "complete",
        pathname: pathname
      });
    });
    return function(request, response, next) {
      var filepath;
      req = request;
      res = response;
      nextFn = next;
      switch (req.method.toUpperCase()) {
        case "GET":
        case "POST":
          pathname = parse(req.url).pathname;
          filepath = path.join(root, pathname);
          return fileTransferer.transfer(filepath);
        default:
          return next();
      }
    };
  };

}).call(this);

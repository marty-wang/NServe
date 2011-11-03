(function() {
  var fs, parse, transfer, _transfer;
  fs = require("fs");
  parse = require("url").parse;
  _transfer = function(req, res) {
    var path;
    path = "." + parse(req.url).pathname;
    return console.log("transfer middleware gets through... for " + path);
  };
  transfer = function() {
    return function(req, res, next) {
      _transfer(req, res);
      return next();
    };
  };
  exports.transfer = transfer;
}).call(this);

(function() {
  var parse, webservice, _isWS, _resHeader, _wsDir;
  parse = require("url").parse;
  _wsDir = 'ws';
  _isWS = function(pathname) {
    return pathname === ("/" + _wsDir) || pathname.indexOf("/" + _wsDir + "/") === 0;
  };
  _resHeader = {
    'Content-Type': "text/plain",
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'X-Requested-With'
  };
  webservice = function() {
    return function(req, res, next) {
      var body, pUrl, pathname, query;
      pUrl = parse(req.url);
      pathname = pUrl.pathname;
      if (_isWS(pathname)) {
        switch (req.method.toUpperCase()) {
          case 'GET':
            query = pUrl.query;
            if ((query != null) && query.indexOf("error") > -1) {
              res.writeHead(404, _resHeader);
              return res.end("GET Failure: " + pathname);
            } else {
              res.writeHead(200, _resHeader);
              return res.end("GET: " + pathname);
            }
            break;
          case 'POST':
            body = req.body;
            if (body['error'] == null) {
              res.writeHead(200, _resHeader);
              return res.end("POST Success: " + pathname);
            } else {
              res.writeHead(404, _resHeader);
              return res.end("POST Failure: " + pathname);
            }
        }
      } else {
        return next();
      }
    };
  };
  exports.webservice = webservice;
}).call(this);

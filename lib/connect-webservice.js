
  exports.connect = function(webservice, wsFolder) {
    var pattern, regEx;
    pattern = "^/" + wsFolder + "/";
    regEx = new RegExp(pattern);
    return function(req, res, next) {
      var errorFile, url;
      url = req.url;
      if (regEx.test(url)) {
        switch (req.method) {
          case 'GET':
            errorFile = req.query['error'];
            return webservice.respond(req, res, errorFile);
          case 'POST':
            errorFile = req.body['error'];
            return webservice.respond(req, res, errorFile);
          default:
            return next();
        }
      } else {
        return next();
      }
    };
  };

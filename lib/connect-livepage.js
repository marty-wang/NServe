(function() {
  var cUtils, colors, fs, insertLiveScript, live, mime, parse, path, util, _liveScript, _types;
  fs = require("fs");
  parse = require("url").parse;
  path = require("path");
  mime = require('mime');
  cUtils = (require("connect")).utils;
  colors = require("colors");
  util = require("./util");
  try {
    _liveScript = fs.readFileSync(path.resolve(__dirname, "../public/live.js"), "utf8");
  } catch (error) {
    _liveScript = null;
    console.error("[".grey + "failed".red + "]".grey + " to load live.js");
  }
  _types = ['text/html', 'text/css', 'application/javascript'];
  live = function(root) {
    return function(req, res, next) {
      var contentType, filepath;
      switch (req.method.toUpperCase()) {
        case "HEAD":
          filepath = root + parse(req.url).pathname;
          contentType = mime.lookup(filepath);
          if (_types.indexOf(contentType >= 0)) {
            return fs.stat(filepath, function(err, stats) {
              if (err == null) {
                res.writeHead(200, {
                  'Content-Type': contentType,
                  'Etag': cUtils.etag(stats)
                });
              }
              return res.end();
            });
          } else {
            return next();
          }
          break;
        default:
          return next();
      }
    };
  };
  insertLiveScript = function(content, contentType) {
    var html, idx;
    if ((_liveScript != null) && contentType === "text/html") {
      html = content.toString('utf8');
      idx = html.lastIndexOf("</body>");
      content = util.strSplice(html, idx, 0, '<script type="text/javascript">' + _liveScript + '</script>');
    }
    return content;
  };
  exports.live = live;
  exports.insertLiveScript = insertLiveScript;
}).call(this);

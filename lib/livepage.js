(function() {
  var LivePage, fs, util;

  fs = require('fs');

  util = require('./util');

  LivePage = (function() {

    function LivePage(liveScriptPath) {
      this._path = liveScriptPath;
      this._script = null;
    }

    LivePage.prototype.insertLiveScript = function(content) {
      var html, idx, result;
      if (this._script == null) {
        try {
          this._script = fs.readFileSync(this._path, 'utf8');
        } catch (error) {
          throw error;
        }
      }
      html = content.toString('utf8');
      idx = html.lastIndexOf("</body>");
      if (idx < 0) {
        throw 'cannot insert live script as no closing body tag is found';
      }
      result = util.strSplice(html, idx, 0, '<script type="text/javascript">' + this._script + '</script>');
      return result;
    };

    return LivePage;

  })();

  exports.create = function(liveScriptPath) {
    return new LivePage(liveScriptPath);
  };

}).call(this);

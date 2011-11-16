(function() {
  var FileTransferer, fsUtil, mime;

  mime = require('mime');

  fsUtil = require('./fs-util');

  FileTransferer = (function() {

    function FileTransferer(dataTransferer, hooks) {
      this._transferer = dataTransferer;
      this._hooks = hooks;
    }

    FileTransferer.prototype.transfer = function(filepath, callback) {
      var _this = this;
      return fsUtil.readStatsAndFile(filepath, function(err, payload) {
        var contentType, data, dataObj, hook, size, _i, _len, _ref;
        if (err != null) {
          return callback(err, null);
        } else {
          data = payload.data;
          size = payload.stats.size;
          contentType = mime.lookup(filepath);
          dataObj = {
            data: data,
            size: size
          };
          _ref = _this._hooks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            hook = _ref[_i];
            hook(contentType, dataObj);
          }
          data = dataObj.data;
          size = dataObj.size;
          callback(null, {
            status: 'start',
            contentType: contentType
          });
          return _this._transferer.transfer(data, size, function(err, result) {
            switch (result.status) {
              case "transfer":
                return callback(null, {
                  status: 'transfer',
                  content: result.payload
                });
              case "complete":
                return callback(null, {
                  status: 'complete',
                  content: result.payload
                });
            }
          });
        }
      });
    };

    return FileTransferer;

  })();

  exports.create = function(dataTransferer, hooks) {
    if (hooks == null) hooks = [];
    return new FileTransferer(dataTransferer, hooks);
  };

}).call(this);

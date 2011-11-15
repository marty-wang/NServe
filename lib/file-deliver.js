(function() {
  var Deliverer, async, fs;
  fs = require('fs');
  async = require('async');
  Deliverer = (function() {
    function Deliverer() {}
    Deliverer.prototype.deliver = function(filepath, callback) {
      return async.series({
        stats: function(go) {
          return fs.stat(filepath, function(err, stats) {
            return go(err, stats);
          });
        },
        fileData: function(go) {
          return fs.readFile(filepath, function(err, data) {
            return go(err, data);
          });
        }
      }, function(err, results) {
        if (err != null) {
          return callback(err, null);
        } else {
          return callback(null, {
            size: results.stats.size,
            data: results.fileData
          });
        }
      });
    };
    return Deliverer;
  })();
  exports.create = function(dataTransferer) {
    return new Deliverer();
  };
}).call(this);

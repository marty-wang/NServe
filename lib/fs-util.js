(function() {
  var async, fs;

  fs = require('fs');

  async = require('async');

  exports.readStatsAndFile = function(filepath, callback) {
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
          stats: results.stats,
          data: results.fileData
        });
      }
    });
  };

}).call(this);

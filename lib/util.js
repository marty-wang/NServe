(function() {
  var absoluteDirPath, fs, path;
  path = require('path');
  fs = require('fs');
  /*
      return absolute directory path or null if it is not valid
  */
  absoluteDirPath = function(pathStr) {
    var absDir, stats;
    if (pathStr == null) {
      return process.cwd();
    }
    pathStr = path.resolve(pathStr);
    try {
      stats = fs.statSync(pathStr);
      if (stats.isDirectory()) {
        absDir = pathStr;
      }
    } catch (error) {
      absDir = null;
    }
    return absDir;
  };
  exports.absoluteDirPath = absoluteDirPath;
}).call(this);

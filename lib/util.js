(function() {
  var absoluteDirPath, fs, getVersionNumber, now, path, strSplice, _packagePath, _root;

  path = require('path');

  fs = require('fs');

  _root = path.resolve(__dirname, "..");

  _packagePath = path.join(_root, "package.json");

  getVersionNumber = function() {
    var packageContent, packageObj, versionNumber;
    try {
      packageContent = fs.readFileSync(_packagePath, "utf8");
      packageObj = JSON.parse(packageContent);
      return versionNumber = packageObj["version"];
    } catch (error) {
      throw error;
    }
  };

  /*
      return absolute directory path or null if it is not valid
  */

  absoluteDirPath = function(pathStr) {
    var absDir, stats;
    if (pathStr == null) return process.cwd();
    pathStr = path.resolve(pathStr);
    try {
      stats = fs.statSync(pathStr);
      if (stats.isDirectory()) absDir = pathStr;
    } catch (error) {
      absDir = null;
    }
    return absDir;
  };

  now = function() {
    var nowArr, nowStr;
    now = new Date();
    nowStr = now.toTimeString();
    nowArr = nowStr.split(' ');
    return "" + nowArr[0] + " " + nowArr[2];
  };

  strSplice = function(string, idx, remove, subStr) {
    return string.slice(0, idx) + subStr + string.slice(idx + Math.abs(remove));
  };

  /* exports
  */

  exports.getVersionNumber = getVersionNumber;

  exports.absoluteDirPath = absoluteDirPath;

  exports.now = now;

  exports.strSplice = strSplice;

}).call(this);

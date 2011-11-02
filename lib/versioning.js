(function() {
  var fs, getVersionNumber, packagePath, path, root;
  path = require("path");
  fs = require("fs");
  root = path.resolve(__dirname, "..");
  packagePath = path.join(root, "package.json");
  getVersionNumber = function() {
    var packageContent, packageObj, versionNumber;
    try {
      packageContent = fs.readFileSync(packagePath, "utf8");
      packageObj = JSON.parse(packageContent);
      return versionNumber = packageObj["version"];
    } catch (error) {
      throw error;
    }
  };
  exports.getVersionNumber = getVersionNumber;
}).call(this);

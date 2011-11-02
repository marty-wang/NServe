path = require "path"
fs = require "fs"

root = path.resolve __dirname, ".."
packagePath = path.join root, "package.json"

getVersionNumber = ->
    try
        packageContent = fs.readFileSync packagePath, "utf8"
        packageObj = JSON.parse packageContent
        versionNumber = packageObj["version"]
    catch error
        throw error

exports.getVersionNumber = getVersionNumber


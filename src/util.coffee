path = require 'path'
fs = require 'fs'

_root = path.resolve __dirname, ".."
_packagePath = path.join _root, "package.json"

getVersionNumber = ->
    try
        packageContent = fs.readFileSync _packagePath, "utf8"
        packageObj = JSON.parse packageContent
        versionNumber = packageObj["version"]
    catch error
        throw error

###
    return absolute directory path or null if it is not valid
###
absoluteDirPath = (pathStr) ->
    return process.cwd() unless pathStr?

    pathStr = path.resolve pathStr

    try
        stats = fs.statSync pathStr
        absDir = pathStr if stats.isDirectory()
    catch error
        absDir = null

    absDir

now = ->
    now = new Date()
    nowStr = now.toTimeString()
    nowArr = nowStr.split ' '
    "#{nowArr[0]} #{nowArr[2]}"
    
### exports ###

exports.getVersionNumber = getVersionNumber
exports.absoluteDirPath = absoluteDirPath
exports.now = now

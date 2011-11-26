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
    return null unless pathStr?

    pathStr = path.resolve pathStr

    try
        stats = fs.statSync pathStr
        absDir = if stats.isDirectory() then pathStr else null
    catch error
        absDir = null

    absDir

now = ->
    now = new Date()
    nowStr = now.toTimeString()
    nowArr = nowStr.split ' '
    "#{nowArr[0]} #{nowArr[2]}"

strSplice = (string, idx, remove, subStr) ->
    string.slice(0,idx) + subStr + string.slice(idx + Math.abs(remove))
    
### exports ###

exports.getVersionNumber = getVersionNumber
exports.absoluteDirPath = absoluteDirPath
exports.now = now
exports.strSplice = strSplice

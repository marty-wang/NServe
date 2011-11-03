path = require 'path'
fs = require 'fs'

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
      
exports.absoluteDirPath = absoluteDirPath

now = ->
    now = new Date()
    nowStr = now.toTimeString()
    nowArr = nowStr.split ' '
    "#{nowArr[0]} #{nowArr[2]}"

exports.now = now
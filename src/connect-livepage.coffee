fs = require "fs"
parse = require("url").parse
path = require "path"

mime = require 'mime'
cUtils = (require "connect").utils
colors = require "colors"

util = require "./util"

try
    _liveScript = fs.readFileSync path.resolve(__dirname, "../public/live.js"), "utf8"
catch error
    _liveScript = null
    console.error "[".grey + "failed".red + "]".grey + " to load live.js"

# add file types that livepage should monitor
_types = [
    'text/html'
    'text/css'
    'application/javascript'
]

live = (root) ->

    (req, res, next) ->
        switch req.method.toUpperCase()
            when "HEAD"
                filepath = root + parse(req.url).pathname
                contentType = mime.lookup filepath
                if _types.indexOf contentType >= 0
                    fs.stat filepath, (err, stats) ->
                        unless err?
                            res.writeHead 200, {
                                'Content-Type': contentType
                                'Etag': cUtils.etag(stats)
                            }
                        res.end()
                else
                    next()
            else
                next()

insertLiveScript = (content, contentType) ->

    if _liveScript? and contentType is "text/html"
        html = content.toString 'utf8'
        idx = html.lastIndexOf "</body>"
        content = util.strSplice html, idx, 0, '<script type="text/javascript">'+_liveScript+'</script>'
    content

exports.live = live
exports.insertLiveScript = insertLiveScript

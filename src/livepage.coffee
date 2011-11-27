fs = require 'fs'

util = require './util'

class LivePage

    constructor: (liveScriptPath) ->
        @_path = liveScriptPath
        @_script = null

    insertLiveScript: (content)->
        unless @_script?
            try
              @_script = fs.readFileSync @_path, 'utf8'
            catch error
              throw error

        html = content.toString 'utf8'
        idx = html.lastIndexOf "</body>"
        if idx < 0
            throw 'cannot insert live script as no closing body tag is found'

        result = util.strSplice html, idx, 0, '<script type="text/javascript">'+@_script+'</script>'
        result

exports.create = (liveScriptPath) ->
    new LivePage liveScriptPath
parse = require("url").parse

# TODO: add timeout var

# should be configurable
_wsDir = 'ws'

_isWS = (pathname) ->
    pathname is "/#{_wsDir}" or pathname.indexOf("/#{_wsDir}/") is 0

_resHeader = {
    'Content-Type': "text/plain"
    'Access-Control-Allow-Origin': '*' # for cross-domain ajax
    'Access-Control-Allow-Headers': 'X-Requested-With'
}

webservice = () ->

    (req, res, next) ->

        pUrl = parse(req.url)
        pathname = pUrl.pathname

        if _isWS pathname
            switch req.method.toUpperCase()
                when 'GET'
                    query = pUrl.query
                    
                    # TODO: add logic to get the file based on the pathname
                    # return 404 if file cannot be found
                                        
                    if query? and query.indexOf("error") > -1
                        res.writeHead 404, _resHeader
                        res.end "GET Failure: #{pathname}"
                    else
                        res.writeHead 200, _resHeader
                        res.end "GET: #{pathname}"

                when 'POST'
                    body = req.body

                    unless body['error']?
                        res.writeHead 200, _resHeader
                        res.end "POST Success: #{pathname}"
                    else
                        res.writeHead 404, _resHeader
                        res.end "POST Failure: #{pathname}"
        else
            console.log "should next"
            next()

exports.webservice = webservice
exports.connect = (webservice, wsFolder) ->
    pattern = "^/#{wsFolder}/"
    regEx = new RegExp pattern

    (req, res, next) ->
        url = req.url
        if regEx.test url
            switch req.method
                when 'GET'
                    errorFile = req.query['error']
                    webservice.respond req, res, errorFile
                when 'POST'
                    errorFile = req.body['error']
                    webservice.respond req, res, errorFile
                else
                    next()
        else
            next()

fs = require "fs"
parse = require("url").parse
path = require 'path'

exports.connect = (fileTransferer, root, callback) ->
    req = null
    res = null
    nextFn = null
    pathname = null

    asyncCallback = (error, payload) ->
        process.nextTick(->
            callback error, payload
        ) if callback?

    fileTransferer.on 'error', (error) ->
        asyncCallback error, pathname
        nextFn()

    fileTransferer.on 'start', (data) ->
        res.writeHead 200, {
            'Content-Type': data
        }
        asyncCallback null, {
            status: 'start'
            pathname: pathname
        }

    fileTransferer.on 'transfer', (data) ->
        res.write data

    fileTransferer.on 'complete', (data) ->
        res.end data
        asyncCallback null,  {
            status: "complete"
            pathname: pathname
        }

    (request, response, next) ->
        req = request
        res = response
        nextFn = next

        switch req.method.toUpperCase()
            when "GET", "POST"
                pathname = parse(req.url).pathname
                filepath = path.join root, pathname

                fileTransferer.transfer filepath
            else
                next()

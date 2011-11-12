nomnom = require 'nomnom'

_coerceInt = (val, name) ->
    val = parseInt val, 10
    val = _defaults[name] if isNaN val
    val

_coerceBool = (val) ->
    !! val

_coerceDefault = (val, name) ->
    val = _defaults[name] unless val?
    val

_options = {
    'port': _coerceInt
    'rate': null
    'verbose': _coerceBool
    'webserviceFolder': null
    'webserviceDelay': _coerceInt
    'liveReload': _coerceBool
    'root': _coerceDefault
}

_defaults = null
_isSetup = false

exports.defaults = (defaults = {}) ->
    return exports if _isSetup

    _defaults = defaults
    nomnom
        .script('nserve')
        .option('root', {
            position: 0
            help: 'directory where files are served [current folder]'
        })
        .option('version', {
            flag: true
            help: 'print out the version number'
            callback: () ->
                return "Version: #{defaults.version}"   
        })
        .option('port', {
            abbr: 'p'
            default: defaults.port
            metavar: 'PORT'
            help: "specify the port number [#{defaults.port}]"        
        })
        .option('rate', {
            abbr: 'r'
            default: defaults.rate
            metavar: 'RATE'
            help: "specify the file transfer rate in Bps, e.g. 100K or 5M [#{defaults.rate}]"        
        })
        .option('webserviceFolder', {
            abbr: 'W'
            full: 'webservice-folder'
            metavar: 'FOLDER'
            default: defaults.webserviceFolder
            help: "specify the webservice folder name [#{defaults.webserviceFolder}]"
        })
        .option('webserviceDelay', {
            abbr: 'D'
            full: 'webservice-delay'
            metavar: 'DELAY'
            default: defaults.webserviceDelay
            help: "specify the delay of the web service in millisecond [#{defaults.webserviceDelay}]"
        })
        .option('verbose', {
            abbr: 'v'
            flag: true
            help: 'enter verbose mode'
        })
        .option('liveReload', {
            abbr: 'L'
            full: 'live-reload'
            flag: true
            help: 'automatically reload HTML/CSS/JS files'
        })

    _isSetup = true
    exports

exports.parse = (argv) ->
    throw 'CLI parser does not have defaults yet' unless _isSetup

    parsed = nomnom.parse argv

    result = {}
    for option, fn of _options
        val = parsed[option]
        val = fn val, option if fn?
        result[option] = val

    result

exports.argv = () ->
    input = process.argv.slice 2
    exports.parse input
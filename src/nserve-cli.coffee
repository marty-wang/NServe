program = require 'commander'

DEFAULT_PORT = 3000

_options = [
    'args',
    'port'
]

_coercePort = (val) ->
    val = parseInt val, 10
    val = DEFAULT_PORT if isNaN val
    val

exports.parse = (argv, version) ->
    program
        .version(version)
        .option('-p, --port <n>', 'specify the port number [3000]', _coercePort, DEFAULT_PORT)
        .parse argv
    
    for option in _options
        exports[option] = program[option]

    exports.version = program.version()
    
    exports

exports.DEFAULT_PORT = DEFAULT_PORT
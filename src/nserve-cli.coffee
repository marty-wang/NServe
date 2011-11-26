Command = (require 'commander').Command

class Parser
    constructor: (argv, defaults) ->
        @_defaults = defaults
        @_program = new Command()
        @_program
            .version(defaults.version)
            .option('-h, --help', 'output usage information')
            .on('help', ->
                @.emit '--help'
                process.stdout.write @.helpInformation()
                process.exit 0
            )
            .usage('[options] [root]')
            .option('-p, --port <number>', "specify the port number [#{defaults.port}]", parseInt, defaults.port)
            .option('-r, --rate <string>', "specify the file transfer rate in Bps, e.g. 100K or 5M [#{defaults.rate}]", defaults.rate)
            .option('-W, --webservice-folder <string>', "specify the webservice folder name")
            .option('-D, --webservice-delay <number>', "specify the delay of the web service in millisecond [#{defaults.webserviceDelay}]", parseInt, defaults.webserviceDelay)
            .option('-v, --verbose', "user the verbose mode")
            .option('-L, --live-reload', "automatically reload HTML/CSS/JS files")
            .parse argv

        @_program.verbose = !!@_program.verbose
        @_program.liveReload = !!@_program.liveReload

    option: (name) ->
        @_program[name]

    root: () ->
        val = @_program.args[0]
        unless val?
            val = @_defaults.root
        val

exports.parse = (argv, defaults) ->
    new Parser argv, defaults

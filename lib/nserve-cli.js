(function() {
  var Command, Parser;

  Command = (require('commander')).Command;

  Parser = (function() {

    function Parser(argv, defaults) {
      this._defaults = defaults;
      this._program = new Command();
      this._program.version(defaults.version).option('-h, --help', 'output usage information').on('help', function() {
        this.emit('--help');
        process.stdout.write(this.helpInformation());
        return process.exit(0);
      }).usage('[options] [root]').option('-p, --port <number>', "specify the port number [" + defaults.port + "]", parseInt, defaults.port).option('-r, --rate <string>', "specify the file transfer rate in Bps, e.g. 100K or 5M [" + defaults.rate + "]", defaults.rate).option('-W, --webservice-folder <string>', "specify the webservice folder name [" + defaults.webserviceFolder + "]", defaults.webserviceFolder).option('-D, --webservice-delay <number>', "specify the delay of the web service in millisecond [" + defaults.webserviceDelay + "]", parseInt, defaults.webserviceDelay).option('-v, --verbose', "user the verbose mode").option('-L, --live-reload', "automatically reload HTML/CSS/JS files").parse(argv);
      this._program.verbose = !!this._program.verbose;
      this._program.liveReload = !!this._program.liveReload;
    }

    Parser.prototype.option = function(name) {
      return this._program[name];
    };

    Parser.prototype.root = function() {
      var val;
      val = this._program.args[0];
      if (val == null) val = this._defaults.root;
      return val;
    };

    return Parser;

  })();

  exports.parse = function(argv, defaults) {
    return new Parser(argv, defaults);
  };

}).call(this);

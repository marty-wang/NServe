(function() {
  var DEFAULT_PORT, program, _coercePort, _options;
  program = require('commander');
  DEFAULT_PORT = 3000;
  _options = ['args', 'port'];
  _coercePort = function(val) {
    val = parseInt(val, 10);
    if (isNaN(val)) {
      val = DEFAULT_PORT;
    }
    return val;
  };
  exports.parse = function(argv, version) {
    var option, _i, _len;
    program.version(version).option('-p, --port <n>', 'specify the port number [3000]', _coercePort, DEFAULT_PORT).parse(argv);
    for (_i = 0, _len = _options.length; _i < _len; _i++) {
      option = _options[_i];
      exports[option] = program[option];
    }
    exports.version = program.version();
    return exports;
  };
  exports.DEFAULT_PORT = DEFAULT_PORT;
}).call(this);

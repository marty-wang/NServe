(function() {
  var nomnom, _coerceBool, _coerceDefault, _coerceInt, _defaults, _isSetup, _options;
  nomnom = require('nomnom');
  _coerceInt = function(val, name) {
    val = parseInt(val, 10);
    if (isNaN(val)) {
      val = _defaults[name];
    }
    return val;
  };
  _coerceBool = function(val) {
    return !!val;
  };
  _coerceDefault = function(val, name) {
    if (val == null) {
      val = _defaults[name];
    }
    return val;
  };
  _options = {
    'port': _coerceInt,
    'rate': null,
    'verbose': _coerceBool,
    'webserviceFolder': null,
    'webserviceDelay': _coerceInt,
    'liveReload': _coerceBool,
    'root': _coerceDefault
  };
  _defaults = null;
  _isSetup = false;
  exports.defaults = function(defaults) {
    if (defaults == null) {
      defaults = {};
    }
    if (_isSetup) {
      return exports;
    }
    _defaults = defaults;
    nomnom.script('nserve').option('root', {
      position: 0,
      help: 'directory where files are served [current folder]'
    }).option('version', {
      flag: true,
      help: 'print out the version number',
      callback: function() {
        return "Version: " + defaults.version;
      }
    }).option('port', {
      abbr: 'p',
      "default": defaults.port,
      metavar: 'PORT',
      help: "specify the port number [" + defaults.port + "]"
    }).option('rate', {
      abbr: 'r',
      "default": defaults.rate,
      metavar: 'RATE',
      help: "specify the file transfer rate in Bps, e.g. 100K or 5M [" + defaults.rate + "]"
    }).option('webserviceFolder', {
      abbr: 'W',
      full: 'webservice-folder',
      metavar: 'FOLDER',
      "default": defaults.webserviceFolder,
      help: "specify the webservice folder name [" + defaults.webserviceFolder + "]"
    }).option('webserviceDelay', {
      abbr: 'D',
      full: 'webservice-delay',
      metavar: 'DELAY',
      "default": defaults.webserviceDelay,
      help: "specify the delay of the web service in millisecond [" + defaults.webserviceDelay + "]"
    }).option('verbose', {
      abbr: 'v',
      flag: true,
      help: 'enter verbose mode'
    }).option('liveReload', {
      abbr: 'L',
      full: 'live-reload',
      flag: true,
      help: 'automatically reload HTML/CSS/JS files'
    });
    _isSetup = true;
    return exports;
  };
  exports.parse = function(argv) {
    var fn, option, parsed, result, val;
    if (!_isSetup) {
      throw 'CLI parser does not have defaults yet';
    }
    parsed = nomnom.parse(argv);
    result = {};
    for (option in _options) {
      fn = _options[option];
      val = parsed[option];
      if (fn != null) {
        val = fn(val, option);
      }
      result[option] = val;
    }
    return result;
  };
  exports.argv = function() {
    var input;
    input = process.argv.slice(2);
    return exports.parse(input);
  };
}).call(this);

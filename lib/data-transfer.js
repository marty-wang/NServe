(function() {
  var DEFAULT_RATE, DEFAULT_SPEAD, getRate, parseRate, transferData, transferRateRegEx, _bufLen, _rate, _speed, _transfer;
  DEFAULT_RATE = "500K";
  DEFAULT_SPEAD = 512000;
  /* Private */
  _speed = DEFAULT_SPEAD;
  _bufLen = Math.round(_speed / 8);
  _rate = DEFAULT_RATE;
  _transfer = function(data, size, offset, bufLength, fn) {
    var chunk;
    bufLength = Math.min(bufLength, size - offset);
    chunk = data.slice(offset, offset + bufLength);
    offset += chunk.length;
    if (fn != null) {
      fn.call(null, {
        status: "transfer",
        payload: chunk
      });
    }
    if (offset >= size) {
      if (fn != null) {
        return fn.call(null, {
          status: "complete"
        });
      }
    }
    return setTimeout((function() {
      return _transfer(data, size, offset, bufLength, fn);
    }), 1000);
  };
  /* Public */
  transferRateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/g;
  parseRate = function(transferRate) {
    var tr, unit;
    tr = transferRateRegEx.exec(transferRate);
    if (tr != null) {
      _speed = tr[1];
      unit = tr[4].toUpperCase();
      _rate = "" + _speed + unit;
      switch (unit) {
        case 'K':
          _speed *= 1024;
          break;
        case 'M':
          _speed *= 1024 * 1024;
      }
      _bufLen = Math.round(_speed / 8);
      return _speed = Math.round(_speed);
    }
  };
  getRate = function() {
    return _rate;
  };
  transferData = function(data, size, fn) {
    return _transfer(data, size, 0, _bufLen, fn);
  };
  exports.parseRate = parseRate;
  exports.getRate = getRate;
  exports.transferData = transferData;
}).call(this);

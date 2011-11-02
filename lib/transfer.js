(function() {
  var transferData, transferRateRegEx, _transfer;
  _transfer = function(data, size, offset, bufLength, fn) {
    var chunk;
    if (offset >= size) {
      if (fn != null) {
        return fn.call(null, {
          status: "complete"
        });
      }
    }
    bufLength = Math.min(bufLength, size - offset);
    chunk = data.slice(offset, offset + bufLength);
    offset += chunk.length;
    if (fn != null) {
      fn.call(null, {
        status: "transfer",
        payload: chunk
      });
    }
    return setTimeout((function() {
      return _transfer(data, size, offset, bufLength, fn);
    }), 1000);
  };
  transferRateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/g;
  transferData = function(data, size, fn, options) {
    var bufLen, speed, tr, transferRate, unit;
    if (options == null) {
      options = {};
    }
    speed = 512000;
    transferRate = options.transferRate;
    tr = transferRateRegEx.exec(transferRate);
    if (tr != null) {
      speed = tr[1];
      unit = tr[4].toLowerCase();
      switch (unit) {
        case 'k':
          speed *= 1024;
          break;
        case 'm':
          speed *= 1024 * 1024;
      }
      speed = Math.round(speed);
    }
    bufLen = Math.round(speed / 8);
    return _transfer(data, size, 0, bufLen, fn);
  };
  exports.transferData = transferData;
}).call(this);

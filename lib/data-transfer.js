(function() {
  var Transferer, rateRegEx;
  rateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/;
  Transferer = (function() {
    var _parse, _transfer;
    function Transferer(rate) {
      this._rate = rate;
      this._bufLen = null;
      _parse.call(this);
    }
    Transferer.prototype.getActualRate = function() {
      return this._rate;
    };
    Transferer.prototype.getBufferLength = function() {
      return this._bufLen;
    };
    Transferer.prototype.transfer = function(data, size, callback) {
      if (this._bufLen <= 0) {
        return callback(null, {
          status: 'complete',
          payload: data
        });
      } else {
        return _transfer(data, size, 0, this._bufLen, callback);
      }
    };
    /* Private */
    _parse = function() {
      var tr, unit;
      tr = rateRegEx.exec(this._rate);
      if (tr != null) {
        this._bufLen = tr[1];
        unit = tr[4].toUpperCase();
        this._rate = "" + this._bufLen + unit;
        switch (unit) {
          case 'K':
            this._bufLen *= 1024;
            break;
          case 'M':
            this._bufLen *= 1024 * 1024;
        }
        return this._bufLen = Math.round(this._bufLen);
      } else {
        this._rate = 'unlimited';
        return this._bufLen = 0;
      }
    };
    _transfer = function(data, size, offset, bufLength, cb) {
      var chunk;
      bufLength = Math.min(bufLength, size - offset);
      chunk = data.slice(offset, offset + bufLength);
      offset += chunk.length;
      if (cb != null) {
        cb(null, {
          status: "transfer",
          payload: chunk
        });
      }
      if (offset >= size) {
        if (cb != null) {
          return cb(null, {
            status: "complete",
            payload: null
          });
        }
      }
      return setTimeout((function() {
        return _transfer(data, size, offset, bufLength, cb);
      }), 1000);
    };
    return Transferer;
  })();
  exports.create = function(rate) {
    return new Transferer(rate);
  };
}).call(this);

(function() {
  var Transferer, rateRegEx;
  rateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/;
  Transferer = (function() {
    var _parse;
    function Transferer(rate) {
      this._rate = rate;
      this._bufLen = 0;
      _parse.call(this);
    }
    Transferer.prototype.getRate = function() {
      return this._rate;
    };
    Transferer.prototype.getBufferLength = function() {
      return this._bufLen;
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
    return Transferer;
  })();
  exports.create = function(rate) {
    return new Transferer(rate);
  };
}).call(this);

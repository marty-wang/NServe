(function() {
  var EventEmitter, Transferer, rateRegEx;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  rateRegEx = /^((\d+\.\d+)|(\d+))([mkMK]?)/;

  Transferer = (function() {
    var _parse, _transfer;

    __extends(Transferer, EventEmitter);

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

    Transferer.prototype.transfer = function(data, size) {
      if (this._bufLen <= 0) {
        return this.emit('complete', data);
      } else {
        return _transfer.call(this, data, size, 0, this._bufLen);
      }
    };

    /* Private
    */

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

    _transfer = function(data, size, offset, bufLength) {
      var chunk, status;
      var _this = this;
      bufLength = Math.min(bufLength, size - offset);
      chunk = data.slice(offset, offset + bufLength);
      offset += chunk.length;
      status = offset >= size ? 'complete' : 'transfer';
      this.emit(status, chunk);
      if (offset >= size) return;
      return setTimeout((function() {
        return _transfer.call(_this, data, size, offset, bufLength);
      }), 1000);
    };

    return Transferer;

  })();

  exports.create = function(rate) {
    return new Transferer(rate);
  };

}).call(this);

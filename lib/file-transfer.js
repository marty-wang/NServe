(function() {
  var EventEmitter, FileTransferer, fsUtil, mime;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter = require('events').EventEmitter;

  mime = require('mime');

  fsUtil = require('./fs-util');

  FileTransferer = (function() {

    __extends(FileTransferer, EventEmitter);

    function FileTransferer(dataTransferer, hooks) {
      var _this = this;
      this._transferer = dataTransferer;
      this._hooks = hooks;
      if (dataTransferer == null) return;
      dataTransferer.on('transfer', function(chunk) {
        return _this.emit('transfer', chunk);
      });
      dataTransferer.on('complete', function(chunk) {
        return _this.emit('complete', chunk);
      });
    }

    FileTransferer.prototype.transfer = function(filepath) {
      var _this = this;
      return fsUtil.readStatsAndFile(filepath, function(err, payload) {
        var contentType, data, dataObj, hook, size, _i, _len, _ref;
        if (err != null) {
          return _this.emit('error', err);
        } else {
          data = payload.data;
          size = payload.stats.size;
          contentType = mime.lookup(filepath);
          dataObj = {
            data: data,
            size: size
          };
          _ref = _this._hooks;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            hook = _ref[_i];
            hook(contentType, dataObj);
          }
          data = dataObj.data;
          size = dataObj.size;
          _this.emit('start', contentType);
          return _this._transferer.transfer(data, size);
        }
      });
    };

    return FileTransferer;

  })();

  exports.create = function(dataTransferer, hooks) {
    if (hooks == null) hooks = [];
    return new FileTransferer(dataTransferer, hooks);
  };

}).call(this);

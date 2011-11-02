(function() {
  var now;
  now = function() {
    var nowArr, nowStr;
    now = new Date();
    nowStr = now.toTimeString();
    nowArr = nowStr.split(' ');
    return "" + nowArr[0] + " " + nowArr[2];
  };
  exports.now = now;
}).call(this);

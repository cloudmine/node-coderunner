// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var isTruthy;

  isTruthy = function(value) {
    var ref;
    if (value == null) {
      value = '';
    }
    (ref = value.toString().toLowerCase()) === 'true' || ref === 't' || ref === '1' || ref === 'yes';
    return module.exports = isTruthy;
  };

}).call(this);

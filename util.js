/* 
 * -------------------------------------------------------------------------------
 * util.js
 *
 * Utility functions.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
  , INFO = 1
  , WARN = 2
  , ERROR = 3
  ;

var writeLog = function(msg, logType) {
  var fn = 'info'
    , id = process.env.WORKER_ID? process.env.WORKER_ID: 0
    ;
  if (logType === WARN || logType === ERROR) fn = 'error';
  console[fn]('%d|%s: %s', id, moment().format('YYYY-MM-DD HH:mm:ss.SSS'), msg);
};

var logInfo = function(msg) {
  writeLog(msg, INFO);
};

var logWarn = function(msg) {
  writeLog(msg, WARN);
};

var logError = function(msg) {
  writeLog(msg, ERROR);
};


module.exports = {
  logInfo: logInfo
  , logWarn: logWarn
  , logError: logError
};



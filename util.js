/* 
 * -------------------------------------------------------------------------------
 * util.js
 *
 * Utility functions.
 * ------------------------------------------------------------------------------- 
 */

var moment = require('moment')
  , _ = require('underscore')
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

/* --------------------------------------------------------
 * getGA()
 *
 * Returns the gestational age as a string in the format
 * 'ww d/7' where ww is the week and d is the day of the
 * current week, e.g. 38 2/7 or 32 5/7.
 *
 * Uses a reference date, which is either passed or if
 * not passed it is assumed to be today. The reference
 * date is the date that the gestational age should be
 * computed for. In other words, given the estimated
 * due date and the reference date, what is the
 * gestational age from the perspective of the reference
 * date.
 *
 * Calculation assumes a 40 week pregnancy and subtracts
 * the refDate from the estimated due date, which is
 * also passed as a parameter.
 *
 * param      edd - estimated due date as JS Date or Moment obj
 * param      rDate - the reference date use for the calculation
 * return     GA - as a string in ww d/7 format
 * -------------------------------------------------------- */
var getGA = function(edd, rDate) {
  if (! edd) throw new Error('getGA() must be called with an estimated due date.');
  var estDue = moment(edd)
    , refDate = moment(rDate) || moment()
    , weeks = Math.abs(40 - estDue.diff(refDate, 'weeks') - 1)
    , days = Math.abs(estDue.diff(refDate.add('weeks', 40 - weeks), 'days'))
    ;
  if (_.isNaN(weeks) || ! _.isNumber(weeks)) return '';
  if (_.isNaN(days) || ! _.isNumber(days)) return '';
  if (days >= 7) {
    weeks++;
    days = days - 7;
  }
  return weeks + ' ' + days + '/7';
};


module.exports = {
  logInfo: logInfo
  , logWarn: logWarn
  , logError: logError
  , getGA: getGA
};



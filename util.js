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

/* --------------------------------------------------------
 * calcEdd()
 *
 * Calculate the estimated due date based upon the date of
 * the last mentral period passed. The returned date is a
 * String in YYYY-MM-DD format.
 *
 * NOTE: this function is also included in mercy.js on the
 * client side. Changes made here should also be made there.
 *
 * param       lmp - date of the last mentral period
 * return      edd - due date as a String
 * -------------------------------------------------------- */
var calcEdd = function(lmp) {
  if (! lmp) throw new Error('calcEdd() must be called with the lmp date.');
  var edd
    ;
  if (! (moment(lmp)).isValid()) {
    throw new Error('calcEdd() must be called with a valid date.');
  }
  edd = moment(lmp).add('days', 280);
  return edd.format('YYYY-MM-DD');
};

/* --------------------------------------------------------
 * adjustSelectData()
 *
 * "Adjusts" the selectData list for the passed selectData
 * list to have a selected element that matches key, if key
 * is passed.
 *
 * param       list - the selectData list
 * param       key - the key that matches selectKey
 * return      the new list
 * -------------------------------------------------------- */
var adjustSelectData = function(list, key) {
    var newList = []
      ;
    _.each(list, function(obj) {
      var newObj = {}
        ;
      newObj.selectKey = obj.selectKey;
      newObj.label = obj.label;
      if (key) {
        if (obj.selectKey === key) {
          newObj.selected = true;
        } else {
          newObj.selected = false;
        }
      } else {
        newObj.selected = obj.selected;
      }
      newList.push(newObj);
    });
  return newList;
};

module.exports = {
  logInfo: logInfo
  , logWarn: logWarn
  , logError: logError
  , getGA: getGA
  , calcEdd: calcEdd
  , adjustSelectData: adjustSelectData
};



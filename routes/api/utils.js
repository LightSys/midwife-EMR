/* 
 * -------------------------------------------------------------------------------
 * utils.js
 *
 * Utility functions for API based routing.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , logError = require('../../util').logError
  ;

var resError = function(res, errCode, msg) {
  res.statusCode = errCode;
  if (msg) logError(msg);
  return res.end();
}

/* --------------------------------------------------------
 * tf2Num()
 *
 * Modifies the object passed at the fields passed to turn
 * true or false values to 1 or 0 respectively for the sake
 * of the database.
 *
 * Note: Depends upon the fact that objects are passed as 
 * references so the passed object will be modified to the
 * caller.
 *
 * param       obj
 * param       fields
 * return      undefined
 * -------------------------------------------------------- */
var tf2Num = function(obj, fields) {
  _.forEach(fields, function(f) {
    if (obj[f] === false) obj[f] = 0;
    if (obj[f] === true) obj[f] = 1;
  });
}

module.exports = {
  resError: resError,
  tf2Num: tf2Num
};

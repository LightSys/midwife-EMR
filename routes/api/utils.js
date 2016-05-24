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

/* --------------------------------------------------------
 * statusObject()
 *
 * Returns a status object for use in returning to the client
 * which provides the status of the operation requested.
 *
 * param       req      - the request object
 * param       success  - boolean whether the operation succeeded
 * param       msg      - (optional) message for the client
 * param       payload  - (optional) object for the client, varies per operation
 * return      statusObject
 * -------------------------------------------------------- */
var statusObject = function(req, success, msg, payload) {
  if (! req) {
    throw new Error('statusObject(): Request object must be passed.');
  }
  if (typeof success !== 'boolean') {
    throw new Error('statusObject(): success parameter must be passed.');
  }
  return {
    requestStatus: {
      path: req.path,
      success: success,
      msg: msg,
      payload: payload
    }
  };
};

var errToResponse = function(err) {
  var response = {
        msg: 'An error occurred.',
        statusCode: 400
      }
    , partsRE = / - (.*): (.*)$/
    , partsMatch
    , errKey
    , errMsg
    ;
  partsMatch = err.toString().match(partsRE);
  if (partsMatch) {
    errKey = partsMatch.length > 1? partsMatch[1]: '';
    errMsg = partsMatch.length > 2? partsMatch[2]: '';
  }

  if (errKey && errMsg) response.msg = errKey + ': ' + errMsg;
  return response;
}

module.exports = {
  resError: resError,
  tf2Num: tf2Num,
  statusObject: statusObject,
  errToResponse: errToResponse
};

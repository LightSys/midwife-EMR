/*
 * -------------------------------------------------------------------------------
 * commUtils.js
 *
 * Utility function for the comm layer.
 * -------------------------------------------------------------------------------
 */

var buildChangeObject = require('./changes').buildChangeObject
  , DATA_ADD = getConstants('DATA_ADD')
  , DATA_CHANGE = getConstants('DATA_CHANGE')
  , DATA_DELETE = getConstants('DATA_DELETE')
  ;

/* --------------------------------------------------------
 * socketToUserInfo()
 *
 * Returns a userInfo object with the user and roleInfo
 * objects derived from socket. Also, if user is in attending
 * role, sets the supervisorId field on the userInfo object.
 *
 * If unable to derive the objects, returns void.
 *
 * param       socket
 * return      userInfo or void
 * -------------------------------------------------------- */
var socketToUserInfo = function(socket) {
  var userInfo = {};
  if (socket && socket.request && socket.request.session) {
    userInfo.sessionID = socket.request.sessionID;
    userInfo.supervisorId = null;
    if (socket.request.session.supervisor &&
        _.isNumber(socket.request.session.supervisor.id)) {
      userInfo.supervisorId = socket.request.session.supervisor.id;
    }
    if (socket.request.session.user) {
      userInfo.user = socket.request.session.user;
      if (socket.request.session.roleInfo) {
        userInfo.roleInfo = socket.request.session.roleInfo;
        return userInfo;
      }
    }
  }
  return void 0;
};

/* --------------------------------------------------------
 * getConstants()
 *
 * Return the constant requested by key passed. Allows
 * multiple modules to reference the same set of constants.
 *
 * param       key
 * return      object or string
 * -------------------------------------------------------- */
function getConstants(key) {
  switch (key) {
    case 'CONST':
      return CONST = {
        TYPE: {
          SITE: 'SITE'
          , SYSTEM: 'SYSTEM'
          , DATA: 'DATA'
        }
      };
      break;

    case 'DATA_ADD':
      return 'DATA_ADD';
      break;

    case 'DATA_CHANGE':
      return 'DATA_CHANGE';
      break;

    case 'DATA_DELETE':
      return 'DATA_DELETE';
      break;

    default:
      throw new Error('Unknown key used in getConstants() in commUtils.js.');
  }
}


var sendData = function(key, val, scope) {
  if (key !== DATA_ADD && key !== DATA_CHANGE && key !== DATA_DELETE) {
    throw new Error('Error: sendData() in commUtils.js called with invalid key: ' + key);
  }
  try {
    data = JSON.parse(val)
  } catch (e) {
    console.log('Error in makeSend processing data: ' + e.toString());
    return;
  }
  buildChangeObject(data, key).then(function(data2) {
    // --------------------------------------------------------
    // Broadcast this to the other processes for distribution
    // to all connected clients.
    // --------------------------------------------------------
    process.send({namespace: CONST.TYPE.DATA, data: data2});
  });
};

module.exports = {
  getConstants
  , sendData
  , socketToUserInfo
};

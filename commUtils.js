/*
 * -------------------------------------------------------------------------------
 * commUtils.js
 *
 * Utility function for the comm layer.
 * -------------------------------------------------------------------------------
 */


/* --------------------------------------------------------
 * socketToUserInfo()
 *
 * Returns a userInfo object with the user and roleInfo
 * objects derived from socket. If unable to derive the
 * objects, returns void.
 *
 * param       socket
 * return      userInfo or void
 * -------------------------------------------------------- */
var socketToUserInfo = function(socket) {
  var userInfo = {};
  if (socket && socket.request && socket.request.session) {
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



module.exports = {
  socketToUserInfo: socketToUserInfo
};

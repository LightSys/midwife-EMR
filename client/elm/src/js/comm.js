/* 
 * -------------------------------------------------------------------------------
 * comm.js
 *
 * Interface to the server using Socket.io and the Elm client using ports.
 * ------------------------------------------------------------------------------- 
 */

io = require('socket.io-client');

var SYSTEM_URL = window.location.origin + '/system';
var ioSystem = io.connect(SYSTEM_URL);

var app;

ioSystem.on('system', function(data) {
  if (! app) return;

  // type is a reserved term in Elm, so we rename it before sending it in.
  if (data.type) {
    data.msgType = data.type;
    delete data.type;
  }

  // Elm does not like uppercase keys in records, so rename and remove
  // extraneous nesting while we are at it.
  if (data.data && data.data.SYSTEM_LOG) {
    data.systemLog = data.data.SYSTEM_LOG;
    delete data.data;
  }
  app.ports.systemMessages.send(data);
});

var setApp = function(theApp) {
  app = theApp;
};

module.exports = {
  setApp: setApp
};

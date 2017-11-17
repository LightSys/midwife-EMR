io = require('socket.io-client');
var MESSAGE = 'message';    // All messages use this key so that we are most compatible with websocket API.
var app;                    // Set by setApp().

// --------------------------------------------------------
// Setup a single Socket.io connection to the server.
// --------------------------------------------------------
var ioSocket = io.connect(window.location.origin + '/');

// --------------------------------------------------------
// Error handling.
// --------------------------------------------------------
ioSocket.on('error', function(err) {
  // TODO: catch error such as session timeouts, etc. and deal with properly.
  // Maybe means sending a message via a port to Elm about this?
  if (! app) return;
  console.log('=== Error ==>');
  console.log(err);
  console.log('<== Error ===');
});

ioSocket.on('reconnect_error', function(err) {
  if (! app) return;
  console.log('=== Reconnect Error ==>');
  console.log(err);
  console.log('<== Reconnect Error ===');
});

ioSocket.on('connect_error', function(err) {
  if (! app) return;
  console.log('=== Connect Error ==>');
  console.log(err);
  console.log('<== Connect Error ===');
});

// --------------------------------------------------------
// Handle all messages coming from the server by parsing to
// JSON, performing nominal sanity checks, and passing out
// to handlers for processing.
// --------------------------------------------------------
ioSocket.on(MESSAGE, function(data) {
  // Sanity checks
  if (! app) {
    console.log('ERROR: message received from the server before app has been initialized.');
    return;
  }
  if (! data) {
    console.log('ERROR: message received from the server with no content.');
    return;
  }

  // Parsing to JSON.
  var json;
  try {
    json = JSON.parse(data);
  } catch (e) {
    console.log('ERROR parsing JSON.');
    console.log(e);
    return;
  }

  // Sanity check on minimal message structure for site, system, and data messages.
  if (! json || ! json.namespace || ! json.msgType) {
    console.log('ERROR: message received from the server is in improper format.');
    console.log(json);
  }

  // Send to the Elm client.
  app.ports.incoming.send(json);
});

/* --------------------------------------------------------
 * touchHttpSession()
 *
 * We send an HTTP PUT to the server and we don't care/expect
 * anything in return. This allows the server to refresh and
 * keep alive the session on the non-websockets side of the
 * application even though the client itself is using websockets
 * exclusively for a long time.
 * -------------------------------------------------------- */
var touchHttpSession = function() {
  var req = new XMLHttpRequest();
  req.open('PUT', window.location.origin + '/touch', true);
  req.send();
}

/* --------------------------------------------------------
 * setApp()
 *
 * Save the reference to the Elm client then subscribe to
 * messages coming from the Elm client and send them to
 * the server.
 * -------------------------------------------------------- */
var setApp = function(theApp) {
  app = theApp;

  app.ports.outgoing.subscribe(function(data) {
    // --------------------------------------------------------
    // Discern if the outgoing data is a "touch" to the server
    // on the websocket side so that the same can be done on the
    // HTTP side. These "touches" are for the sake of maintaining
    // the user's session on the server.
    // --------------------------------------------------------
    if (data.msgType && data.msgType === 'ADHOC_TOUCH_SESSION') {
      touchHttpSession();
    }
    ioSocket.send(JSON.stringify(data));
  });
};

module.exports = {
  setApp: setApp
};

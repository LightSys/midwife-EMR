'use strict';

require('./css/fonts.css');
require('../vendor/blaze.min.css');
require('./css/main.css');

var comm = require('./js/comm');
var datepicker = require('./js/datepicker');
var tests = require('./js/tests');
var elm = require('./elm/Medical.elm');
var node = document.getElementById('app');
var pregId = node.getAttribute('data-pregId');
var supportsDate = tests.supportsDateInput? tests.supportsDateInput(): false;
var app = elm.Medical.embed( node,
    {pregId: pregId
    , currTime: Date.now()
    , browserSupportsDate: supportsDate
    });
comm.setApp(app);
datepicker.setApp(app);

// Websocket testing.
var WS_TEST = 0;  // Set to 1 to use.
if (1 === WS_TEST) {
  var socket = new WebSocket("wss://" + window.location.host + "/wstest");

  socket.onclose = function(evt) {
    console.log('--- Close ---');
    if (evt.reason && evt.reason.length > 0) {
      console.log(evt.reason);
    }
    console.log(evt);
  };

  socket.onopen = function(evt) {
    console.log('--- Open ---');
    console.log(evt);
    socket.send("This is a test.");
  };

  socket.onerror = function(evt) {
    console.log('--- Error ---');
    console.log(evt);
  };

  socket.onmessage = function(evt) {
    console.log('--- Message ---');
    console.log(evt);
  };
}

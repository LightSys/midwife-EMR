'use strict';

require('./css/fonts.css');
require('../vendor/blaze.min.css');
require('../vendor/blaze.colors.min.css');
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

// --------------------------------------------------------
// Send all uncaught errors to the server for storage.
// --------------------------------------------------------
window.onerror = function(msg, url, lineNum, colNum, error) {

  // --------------------------------------------------------
  // Construct the message as a string.
  // --------------------------------------------------------
  var msg = msg? msg: '';
  msg += ' | ' + (url? url: '');
  msg += ' | ' + (typeof lineNum === 'number'? lineNum: '');
  msg += ' | ' + (typeof colNum === 'number'? colNum: '');
  msg += ' | ' + (error? JSON.stringify(error): '');

  comm.errorToServer(msg);

  // Allow the default error handler to fire as well.
  return false;
};

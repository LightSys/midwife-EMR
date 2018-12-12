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
var pregId = node.getAttribute('data-preg_id');
var supportsDate = tests.supportsDateInput? tests.supportsDateInput(): false;
var users = JSON.parse(node.getAttribute('data-users'));
var userId;
var supervisorId;

try {
  userId = parseInt(node.getAttribute('data-user_id'), 10);
  if (isNaN(userId)) throw 'No user id';
} catch (e) {
  // This is not normal under any circumstances, but not necessarily catastrophic.
  userId = -1;
}

try {
  supervisorId = parseInt(node.getAttribute('data-supervisor_id'), 10);
  if (isNaN(supervisorId)) throw 'No supervisor id';
} catch (e) {
  // This is normal unless the role is attending.
  supervisorId = null;
}

var app = elm.Medical.embed( node,
    {pregId: pregId
    , currTime: Date.now()
    , browserSupportsDate: supportsDate
    , users: users? users: []
    , userId: userId
    , supervisorId: supervisorId
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

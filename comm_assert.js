/*
 * -------------------------------------------------------------------------------
 * comm_assert.js
 *
 * Verifies parameters of functions in the comm.js module.
 * -------------------------------------------------------------------------------
 */
var assert = require('assert')
    _ = require('underscore')
    msg = require('./util').msg
    verbose = true
  ;

function ioData_socket_on_ADD(payload) {
  var m = msg('comm_assert/ioData_socket_on_ADD()');
  if (verbose) console.log(m());

  assert.ok(_.isString(payload), m('payload'));
}

function ioData_socket_on_CHG(payload) {
  var m = msg('comm_assert/ioData_socket_on_CHG()');
  if (verbose) console.log(m());

  assert.ok(_.isString(payload), m('payload'));
}

function ioData_socket_on_DEL(payload) {
  var m = msg('comm_assert/ioData_socket_on_DEL()');
  if (verbose) console.log(m());

  assert.ok(_.isString(payload), m('payload'));
}

function ioData_socket_on_DATA_SELECT(data) {
  var m = msg('comm_assert/ioData_socket_on_DATA_SELECT()');
  if (verbose) console.log(m());

  assert.ok(JSON.parse(data), m('JSON.parse'));

  var json = JSON.parse(data);
  assert.ok(_.has(json, 'table'), m('table'));
  assert.ok(_.has(json, 'id') && _.isNumber(json.id), m('id'));
  assert.ok(_.has(json, 'pregnancy_id') && _.isNumber(json.pregnancy_id), m('pregnancy_id'));
  assert.ok(_.has(json, 'patient_id') && _.isNumber(json.patient_id), m('patient_id'));
}

function ioData_socket_on_ADHOC(data) {
  var m = msg('comm_assert/ioData_socket_on_ADHOC()');
  if (verbose) console.log(m());

  assert.ok(JSON.parse(data), m('JSON.parse'));

  var json = JSON.parse(data);
  assert.ok(_.has(json, 'adhocType'), m('adhocType'));
}

function handleData(evtName, payload, socket) {
  var m = msg('comm_assert/handleData()');
  if (verbose) console.log(m());

  assert.ok(_.isString(evtName), m('evtName'));
  assert.ok(evtName === 'ADD' || evtName === 'CHG' || evtName === 'DEL', m('evtName values'));

  assert.ok(_.isString(payload), m('payload'));
  assert.ok(JSON.parse(payload), m('JSON.parse'));

  var json = JSON.parse(payload);
  assert.ok(_.has(json, 'table') && _.isString(json.table), m('payload.table'));
  assert.ok(_.has(json, 'data') && _.isObject(json.data), m('payload.data'));
  assert.ok(_.has(json.data, 'id') && _.isNumber(json.data.id), m('payload.data.id'));
}

function handleLogin(json, socket) {
  var m = msg('comm_assert/handleLogin()');
  if (verbose) console.log(m());

  // Note: we don't check json.username and json.password because the
  // handleLogin() function already does that and responds to the
  // client accordingly in the normal course of operations.
  assert.ok(socket, m('socket'));
  assert.ok(_.isFunction(socket.emit), m('emit'));
}

function sendUserProfile(socket, user, errCode) {
  var m = msg('comm_assert/sendUserProfile()');
  if (verbose) console.log(m());

  assert.ok(socket, m('socket'));
  assert.ok(user, m('user'));
  assert.ok(errCode, m('errCode'));

  assert.ok(_.isFunction(socket.request.session.save), m('socket.save'));

  assert.ok(user.roleName || user.role && user.role.name, m('user.roleName or user.role.name'));
  assert.ok(user.userId || user.id, m('userId or id'));
  assert.ok(user.username, m('username'));
  assert.ok(user.firstname, m('firstname'));
  assert.ok(user.lastname, m('lastname'));
  assert.ok(_.isString(user.email), m('email'));
  assert.ok(_.isString(user.lang), m('lang'));
  assert.ok(_.isString(user.shortName), m('shortName'));
  assert.ok(_.isString(user.displayName), m('displayName'));
  assert.ok(_.isNumber(user.role_id), m('role_id'));
}

function handleUserProfile(socket, data, userInfo) {
  var m = msg('comm_assert/handleUserProfile()');
  if (verbose) console.log(m());

  // Either the user object is not there, or if it is then
  // it has an id.
  assert.ok(! socket.request.session.user ||
    _.isNumber(socket.request.session.user.id), m('user.id'));
}

function isValidSocketSession(socket) {
  var m = msg('comm_assert/isValidSocketSession()');
  if (verbose) console.log(m());

  assert.ok(socket, m('socket'));
  assert.ok(socket.request, m('socket.request'));
  assert.ok(socket.request.session, m('socket.request.session'));
  assert.ok(socket.request.session.cookie, m('socket.request.session.cookie'));
  assert.ok(socket.request.session.cookie._expires
      , m('socket.request.session.cookie._expires'));
}

function touchSocketSession(socket) {
  var m = msg('comm_assert/touchSocketSession()');
  if (verbose) console.log(m());

  assert.ok(socket, m('socket'));
  assert.ok(_.isFunction(socket.request.session.touch), m('touch'));
}

module.exports = {
  handleData,
  handleLogin,
  handleUserProfile,
  ioData_socket_on_ADD,
  ioData_socket_on_CHG,
  ioData_socket_on_DEL,
  ioData_socket_on_ADHOC,
  ioData_socket_on_DATA_SELECT,
  isValidSocketSession,
  sendUserProfile,
  touchSocketSession
};

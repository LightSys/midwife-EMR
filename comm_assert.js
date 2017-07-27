/*
 * -------------------------------------------------------------------------------
 * comm_assert.js
 *
 * Verifies parameters of functions in the comm.js module.
 * -------------------------------------------------------------------------------
 */

var UserProfileFailErrorCode = require('./util').UserProfileFailErrorCode
  ;

var assert = require('assert')
    _ = require('underscore')
    msg = require('./util').msg
    verbose = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  ;

function ioData_socket_on_ADD(payload) {
  var m = msg('comm_assert/ioData_socket_on_ADD()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(payload), m('payload'));
}

function ioData_socket_on_CHG(payload) {
  var m = msg('comm_assert/ioData_socket_on_CHG()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(payload), m('payload'));
}

function ioData_socket_on_DEL(payload) {
  var m = msg('comm_assert/ioData_socket_on_DEL()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(payload), m('payload'));
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

function getTable(socket, json) {
  var m = msg('comm_assert/getTable()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(json), m('json'));
  assert.ok(_.has(json, 'version'), m('version'));
  assert.ok(_.isNumber(json.version) && (json.version === 1), m('version value'));

  // Version 1 fields within the payload field
  assert.ok(_.has(json, 'payload') && _.isObject(json.payload), m('json.payload'));
  assert.ok(_.has(json.payload, 'id'), m('json.payload.id'));
  assert.ok(_.has(json.payload, 'patient_id'), m('json.payload.patient_id'));
  assert.ok(_.has(json.payload, 'pregnancy_id'), m('json.payload.pregnancy_id'));

}

function handleData(evtName, payload, socket) {
  var m = msg('comm_assert/handleData()');
  if (verbose) console.log(m());

  assert.ok(_.isString(evtName), m('evtName'));
  assert.ok(evtName === 'ADD' || evtName === 'CHG' || evtName === 'DEL', m('evtName values'));

  assert.ok(_.isObject(payload), m('payload'));

  assert.ok(_.has(payload, 'table') && _.isString(payload.table), m('payload.table'));
  assert.ok(_.has(payload, 'data') && _.isObject(payload.data), m('payload.data'));
  assert.ok(_.has(payload.data, 'id') && _.isNumber(payload.data.id), m('payload.data.id'));
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
  assert.ok(user || errCode === UserProfileFailErrorCode, m('user'));
  assert.ok(errCode, m('errCode'));

  assert.ok(_.isFunction(socket.request.session.save), m('socket.save'));

  if (user) {
    assert.ok(user.roleName || user.role && user.role.name, m('user.roleName or user.role.name'));
    assert.ok(user.userId || user.id, m('userId or id'));
    assert.ok(user.username, m('username'));
    assert.ok(user.firstname, m('firstname'));
    assert.ok(user.lastname, m('lastname'));
    assert.ok(_.isNumber(user.role_id), m('role_id'));
  }
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
  getTable,
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

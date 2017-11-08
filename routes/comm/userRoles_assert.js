/*
 * -------------------------------------------------------------------------------
 * userRoles_assert.js
 *
 * Verifies parameters of functions in the userRoles.js module.
 * -------------------------------------------------------------------------------
 */
var assert = require('assert')
    _ = require('underscore')
    msg = require('../../util').msg
    verbose = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  ;

function getUserProfile(id, cb) {
  var m = msg('userRoles_assert/getUserProfile()');
  if (verbose) console.log(m());

  assert.ok(_.isNumber(id), m('id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(cb.length === 3, m('cb arguments'));
}

function updateUserProfile(data, userInfo, cb) {
  var m = msg('userRoles_assert/updateUserProfile()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'userId') && _.isNumber(data.userId), m('data.userId'));
  assert.ok(_.isString(data.password), m('data.password'));

  assert.ok(_.isObject(userInfo), m('userInfo'));
  assert.ok(_.has(userInfo, 'user') && _.isObject(userInfo.user), m('userInfo.user'));
  assert.ok(_.has(userInfo.user, 'id') && _.has(userInfo.user, 'supervisor'), m('userInfo.user flds'));

  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(cb.length === 3, m('cb arguments'));
}

module.exports = {
  getUserProfile,
  updateUserProfile
};

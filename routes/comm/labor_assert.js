/*
 * -------------------------------------------------------------------------------
 * labor_assert.js
 *
 * Asserts for the labor, delivery, and postpartum data managment routines.
 * -------------------------------------------------------------------------------
 */

var assert = require('assert')
    _ = require('underscore')
    msg = require('../../util').msg
    verbose = true
  ;

var addLabor = function(data, cb) {
  var m = msg('labor_assert/addLabor()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

module.exports = {
  addLabor
};

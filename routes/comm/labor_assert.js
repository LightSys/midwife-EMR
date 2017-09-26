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

var addLaborStage1 = function(data, cb) {
  var m = msg('labor_assert/addLaborStage1()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'fullDialation'), m('data.fullDialation'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

var updateLaborStage1 = function(data, cb) {
  var m = msg('labor_assert/updateLaborStage1()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'fullDialation'), m('data.fullDialation'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

module.exports = {
  addLabor,
  addLaborStage1,
  updateLaborStage1
};

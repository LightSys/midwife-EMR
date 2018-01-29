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

var addMembranesResus = function(data, cb) {
  var m = msg('labor_assert/addMembranesResus()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateMembranesResus = function(data, cb) {
  var m = msg('labor_assert/updateMembranesResus()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addApgar = function(data, cb) {
  var m = msg('labor_assert/addApgar()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding an apgar should not have an id.
  assert.ok(_.has(data, 'minute'), m('data.minute'));
  assert.ok(_.has(data, 'score'), m('data.score'));
  assert.ok(_.has(data, 'baby_id'), m('data.baby_id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateApgar = function(data, cb) {
  var m = msg('labor_assert/updateApgar()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'minute'), m('data.minute'));
  assert.ok(_.has(data, 'score'), m('data.score'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addBaby = function(data, cb) {
  var m = msg('labor_assert/addBaby()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a baby should not have an id.
  assert.ok(_.has(data, 'sex'), m('data.sex'));
  assert.ok(data.sex !== 'F' || data.sex !== 'M', m('data.sex values'));
  assert.ok(_.has(data, 'birthWeight') && _.isNumber(data.birthWeight), m('data.birthWeight'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateBaby = function(data, cb) {
  var m = msg('labor_assert/updateBaby()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'sex'), m('data.sex'));
  assert.ok(data.sex !== 'F' || data.sex !== 'M', m('data.sex values'));
  assert.ok(_.has(data, 'birthWeight') && _.isNumber(data.birthWeight), m('data.birthWeight'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addLabor = function(data, cb) {
  var m = msg('labor_assert/addLabor()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateLabor = function(data, cb) {
  var m = msg('labor_assert/updateLabor()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
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

var addLaborStage2 = function(data, cb) {
  var m = msg('labor_assert/addLaborStage2()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

var updateLaborStage2 = function(data, cb) {
  var m = msg('labor_assert/updateLaborStage2()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

var addLaborStage3 = function(data, cb) {
  var m = msg('labor_assert/addLaborStage3()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

var updateLaborStage3 = function(data, cb) {
  var m = msg('labor_assert/updateLaborStage3()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(_.has(data, 'labor_id'), m('data.labor_id'));
  assert.ok(_.isNumber(data.labor_id), m('data.labor_id is a number'));
};

module.exports = {
  addApgar,
  updateApgar,
  addBaby,
  updateBaby,
  addLabor,
  updateLabor,
  addLaborStage1,
  updateLaborStage1,
  addLaborStage2,
  updateLaborStage2,
  addLaborStage3,
  updateLaborStage3,
  addMembranesResus,
  updateMembranesResus
};

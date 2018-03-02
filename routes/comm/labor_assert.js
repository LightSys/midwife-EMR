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

var addPostpartumCheck = function(data, cb) {
  var m = msg('labor_assert/addPostpartumCheck()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a postpartumCheck should not have an id.
  assert.ok(_.has(data, 'checkDatetime'), m('data.checkDatetime'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updatePostpartumCheck = function(data, cb) {
  var m = msg('labor_assert/updatePostpartumCheck()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'checkDatetime'), m('data.checkDatetime'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addDischarge = function(data, cb) {
  var m = msg('labor_assert/addDischarge()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a discharge should not have an id.
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateDischarge = function(data, cb) {
  var m = msg('labor_assert/updateDischarge()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addBabyLab = function(data, cb) {
  var m = msg('labor_assert/addBabyLab()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.has(data, 'babyLabType'), m('data.babyLabType'));
  assert.ok(_.isNumber(data.babyLabType), m('data.babyLabType is a number'));
  assert.ok(_.has(data, 'dateTime'), m('data.dateTime'));
  assert.ok(_.has(data, 'fld1Value'), m('data.fld1Value'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateBabyLab = function(data, cb) {
  var m = msg('labor_assert/updateBabyLab()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'babyLabType'), m('data.babyLabType'));
  assert.ok(_.isNumber(data.babyLabType), m('data.babyLabType is a number'));
  assert.ok(_.has(data, 'dateTime'), m('data.dateTime'));
  assert.ok(_.has(data, 'fld1Value'), m('data.fld1Value'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addBabyMedication = function(data, cb) {
  var m = msg('labor_assert/addBabyMedication()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.has(data, 'babyMedicationType'), m('data.babyMedicationType'));
  assert.ok(_.isNumber(data.babyMedicationType), m('data.babyMedicationType is a number'));
  assert.ok(_.has(data, 'medicationDate'), m('data.medicationDate'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateBabyMedication = function(data, cb) {
  var m = msg('labor_assert/updateBabyMedication()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'babyMedicationType'), m('data.babyMedicationType'));
  assert.ok(_.isNumber(data.babyMedicationType), m('data.babyMedicationType is a number'));
  assert.ok(_.has(data, 'medicationDate'), m('data.medicationDate'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addBabyVaccination = function(data, cb) {
  var m = msg('labor_assert/addBabyVaccination()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.has(data, 'babyVaccinationType'), m('data.babyVaccinationType'));
  assert.ok(_.isNumber(data.babyVaccinationType), m('data.babyVaccinationType is a number'));
  assert.ok(_.has(data, 'vaccinationDate'), m('data.vaccinationDate'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateBabyVaccination = function(data, cb) {
  var m = msg('labor_assert/updateBabyVaccination()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'babyVaccinationType'), m('data.babyVaccinationType'));
  assert.ok(_.isNumber(data.babyVaccinationType), m('data.babyVaccinationType is a number'));
  assert.ok(_.has(data, 'vaccinationDate'), m('data.vaccinationDate'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addContPostpartumCheck = function(data, cb) {
  var m = msg('labor_assert/addContPostpartumCheck()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateContPostpartumCheck = function(data, cb) {
  var m = msg('labor_assert/updateContPostpartumCheck()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addNewbornExam = function(data, cb) {
  var m = msg('labor_assert/addNewbornExam()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateNewbornExam = function(data, cb) {
  var m = msg('labor_assert/updateNewbornExam()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addMembrane = function(data, cb) {
  var m = msg('labor_assert/addMembrane()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateMembrane = function(data, cb) {
  var m = msg('labor_assert/updateMembrane()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var addMotherMedication = function(data, cb) {
  var m = msg('labor_assert/addMotherMedication()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(! _.has(data, 'id'), m('data.id')); // Adding a record should not have an id.
  assert.ok(_.has(data, 'motherMedicationType'), m('data.motherMedicationType'));
  assert.ok(_.isNumber(data.motherMedicationType), m('data.motherMedicationType is a number'));
  assert.ok(_.has(data, 'medicationDate'), m('data.medicationDate'));
  assert.ok(_.isFunction(cb), m('cb'));
};

var updateMotherMedication = function(data, cb) {
  var m = msg('labor_assert/updateMotherMedication()');
  if (verbose) console.log(m());

  assert.ok(_.isObject(data), m('data'));
  assert.ok(_.has(data, 'id'), m('data.id'));
  assert.ok(_.has(data, 'motherMedicationType'), m('data.motherMedicationType'));
  assert.ok(_.isNumber(data.motherMedicationType), m('data.motherMedicationType is a number'));
  assert.ok(_.has(data, 'medicationDate'), m('data.medicationDate'));
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
  addBabyLab,
  updateBabyLab,
  addBabyMedication,
  updateBabyMedication,
  addBabyVaccination,
  updateBabyVaccination,
  addContPostpartumCheck,
  updateContPostpartumCheck,
  addDischarge,
  updateDischarge,
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
  addMembrane,
  updateMembrane,
  addMotherMedication,
  updateMotherMedication,
  addNewbornExam,
  updateNewbornExam,
  addPostpartumCheck,
  updatePostpartumCheck
};

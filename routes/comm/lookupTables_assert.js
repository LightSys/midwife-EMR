/*
 * -------------------------------------------------------------------------------
 * lookupTables_assert.js
 *
 * Verifies parameters of functions in the lookupTables.js module.
 * -------------------------------------------------------------------------------
 */
var assert = require('assert')
    _ = require('underscore')
    msg = require('../../util').msg
    verbose = true
  ;

function getLookupTable(table, id, pregnancy_id, patient_id, cb) {
  var m = msg('lookupTables_assert/getLookupTable()');
  if (verbose) console.log(m());

  assert.ok(_.isString(table), m('table'));
  assert.ok(_.isNumber(id), m('id'));
  assert.ok(_.isNumber(pregnancy_id), m('pregnancy_id'));
  assert.ok(_.isNumber(patient_id), m('patient_id'));
  assert.ok(_.isFunction(cb), m('cb'));
  assert.ok(cb.length === 2, m('cb arguments'));
}

module.exports = {
  getLookupTable
};

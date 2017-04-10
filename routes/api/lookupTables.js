/*
 * -------------------------------------------------------------------------------
 * lookupTables.js
 *
 * Retrieve the data in the lookup tables for the application.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , Bookshelf = require('bookshelf')
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  ;

// --------------------------------------------------------
// These are the lookup tables that we service.
// --------------------------------------------------------
var LOOKUP_TABLES = [
  'eventType',
  'labSuite',
  'labTest',
  'medicationType',
  'pregnoteType',
  'riskCode',
  'role',
  'user',
  'vaccinationType'
];


/* --------------------------------------------------------
 * getLookupTable()
 *
 * Return all of the records for the lookup table passed.
 * The requested lookup table must be one of the tables
 * found in LOOKUP_TABLES.
 *
 * Returns an array of objects via the callback in standard
 * Nodejs style.
 *
 * param       table - the table name
 * param       cb
 * -------------------------------------------------------- */
var getLookupTable = function(table, cb) {
  var data = []
    , knex = Bookshelf.DB.knex
    , msg
    ;

  // --------------------------------------------------------
  // Make sure that the table passed is allowed.
  // --------------------------------------------------------
  if (! _.contains(LOOKUP_TABLES, table)) {
    msg = 'lookupTables.getLookupTable(): ' + table + ' is not an allowed table.';
    return cb(msg);
  }

  knex(table)
    .select()
    .then(function(rows) {
      // --------------------------------------------------------
      // We never return the password field to the client. Return
      // an empty string instead.
      // --------------------------------------------------------
      if (table === 'user') {
        rows = _.map(rows, function(rec) {
          rec.password = '';
          return rec;
        });
      }
      return cb(null, rows);
    })
    .catch(function(err) {
      logError(err);
      return cb(err);
    });
}

module.exports = {
  getLookupTable: getLookupTable
}


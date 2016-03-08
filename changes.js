/*
 * -------------------------------------------------------------------------------
 * changes.js
 *
 * Handle change notification for clients.
 * -------------------------------------------------------------------------------
 */

var Bookshelf = require('bookshelf')
  , _ = require('underscore')
  , cfg = require('./config')
  , DATA_CHANGE = 'DATA_CHANGE'
  ;

/* --------------------------------------------------------
 * buildChangeObject()
 *
 * Builds an object representing the meta data about a change
 * for client consumption. The expected input object will
 * have these fields with their respective values at a minimum
 * (although the input object may contain more):
 * table, id, updatedBy.
 *
 * The return promise will yield at least one additional field
 * named type with a value of 'DATA_CHANGE'.  In addition, if
 * the table had any other foreign keys, the key names and
 * key values will be represented too. Example:
 *
 *  { table: 'prenatalExam',
 *    id: 8123,
 *    updatedBy: 23,
 *    pregnancy_id: 972,
 *    type: 'DATA_CHANGE' }
 *
 * param       data - object with table, id, and updatedBy fields
 * return      Promise
 * -------------------------------------------------------- */
var buildChangeObject = function(data) {
  var knex = Bookshelf.DB.knex
    , result = _.extend({}, data)
    ;

  // Add the type field.
  result.type = DATA_CHANGE;

  // Get the foreign keys of the table.
  return knex
    .select('COLUMN_NAME')
    .from('information_schema.KEY_COLUMN_USAGE')
    .where({TABLE_SCHEMA: cfg.database.db, TABLE_NAME: result.table})
    .whereNotNull('referenced_column_name')
    .map(function(row) {
      return row.COLUMN_NAME;
    })
    .then(function(cols) {
      // Get the foreign key values of the record.
      return knex
        .select(cols)
        .from(cfg.database.db + '.' + result.table)
        .where({id: result.id})
        .then(function(rows) {
          return _.extend(result, rows[0]);
        });
    })
    .then(function(result) {
      return result;
    });
};


module.exports = {
  buildChangeObject: buildChangeObject
};


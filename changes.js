/*
 * -------------------------------------------------------------------------------
 * changes.js
 *
 * Handle change notification for clients.
 * -------------------------------------------------------------------------------
 */

"use strict";

var Bookshelf = require('bookshelf')
  , _ = require('underscore')
  , cfg = require('./config')
  , util = require('./util')
  ;

/* --------------------------------------------------------
 * buildChangeObject()
 *
 * Builds an object representing the meta data about a change
 * for client consumption. The expected input object will
 * have these fields with their respective values at a minimum
 * (although the input object may contain more):
 * table and id
 *
 * The return promise will yield at least one additional field
 * named notificationType with a value of the chgType value
 * passed.  In addition, if the table had any other foreign keys,
 * with the exception of the updatedBy and supervisor fields,
 * the key names and key values will be represented too. Example:
 *
 *  { table: 'prenatalExam',
 *    id: 8123,
 *    notificationType: 'DATA_CHANGE',
 *    foreignKeys: [ { table: 'pregnancy', id: 972} ]
 *  }
 *
 * Note: as noted above, the foreign key relationships of the
 * updatedBy and supervisor fields are ignored since almost all
 * tables have these foreign keys and inclusion is not helpful.
 *
 * param       data - object with table and id fields
 * param       type - DATA_ADD or DATA_CHANGE or DATA_DELETE
 * return      Promise
 * -------------------------------------------------------- */
var buildChangeObject = function(data, chgType) {
  const knex = Bookshelf.DB.knex
    , result = _.extend({}, _.omit(data, ['updatedBy']))
    ;

  // Add the type and foreignKeys fields, the latter which is
  // populated below.
  result.notificationType = chgType;
  result.foreignKeys = [];

  // Get the tables and foreign key fields of the foreign keys of the table.
  if (util.dbType() === util.KnexMySQL) {
    return knex
      .select(['COLUMN_NAME', 'REFERENCED_TABLE_NAME'])
      .from('information_schema.KEY_COLUMN_USAGE')
      .where({TABLE_SCHEMA: cfg.database.db, TABLE_NAME: result.table})
      .whereNotNull('REFERENCED_COLUMN_NAME')
      .whereNotIn('COLUMN_NAME', ['updatedBy', 'supervisor'])
      .then(function(refTblCol) {
        //
        // Get the foreign key values for the affected table.
        //
        var cols = _.pluck(refTblCol, 'COLUMN_NAME');
        return knex
          .select(cols)
          .from(cfg.database.db + '.' + result.table)
          .where({id: result.id})
          .then(function(row) {
            //
            // Populate the result object in the proper format.
            //
            // Note: if this is a deletion, row will not be populated,
            // so we have to skip foreign key processing here because
            // we cannot derive foreign key ids for a non-existent row.
            if (! chgType.toLowerCase().includes('del')) {
              _.forEach(refTblCol, function(r) {
                result.foreignKeys.push({table: r.REFERENCED_TABLE_NAME, id: row[0][r.COLUMN_NAME]});
              });
            }
            return result;
          });
      })
      .then(function(result) {
        // TODO: remove this console.log().
        console.log(result);
        return result;
      });
  } else {
    // SQLite3
    //
    //
    // TODO: make changes here to correspond to changes made on MySQL side
    // in relation to what is returned to the Elm client for data changes.
    //
    //
    return knex
      .select('sql')
      .from('sqlite_master')
      .where({name: result.table})
      .map(function(row) {
        return row.sql
      })
      .then(function(sqlArray) {
        // Extract the foreign key names from the sqlite_master table.
        const re = /FOREIGN KEY\s*\((\w*)\)/gm;
        const sql = sqlArray[0]
        const keys = []
        let tmp
        try {
          while ((tmp = re.exec(sql)) !== null) {
            const field = /\(\w*\)/.exec(tmp[0])[0].replace('(','').replace(')','')
            keys.push(field)
          }
        } catch (e) {
          console.log(e)
        }
        return keys
      })
      .then(function(cols) {
        // Get the foreign key values of the record.
        return knex
          .select(cols)
          .from(result.table)
          .where({id: result.id})
          .then(function(rows) {
            return _.extend(result, rows[0]);
          });
      })
      .then(function(result) {
        return result
      })
  }
};


module.exports = {
  buildChangeObject: buildChangeObject
};


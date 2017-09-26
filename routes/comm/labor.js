/*
 * -------------------------------------------------------------------------------
 * labor.js
 *
 * Data management routines for the labor, delivery, and postpartum tables.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , Labor = require('../../models').Labor
  , LaborStage1 = require('../../models').LaborStage1
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , DATA_ADD = require('../../commUtils').getConstants('DATA_ADD')
  , DATA_CHANGE = require('../../commUtils').getConstants('DATA_CHANGE')
  , DATA_DELETE = require('../../commUtils').getConstants('DATA_DELETE')
  , sendData = require('../../commUtils').sendData
  , assertModule = require('./labor_assert')
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  , moduleTables = {}
  ;

// --------------------------------------------------------
// These are ALL of the tables that this module modifies
// and the list of date fields that need a UTC to localtime
// conversion applied upon insert/update, if any. 
//
// Note that every table needs to be listed even if there 
// are no date fields present in the table.
// --------------------------------------------------------
moduleTables.labor = ['admittanceDate', 'startLaborDate'];
moduleTables.laborStage1 = ['fullDialation'];


/* --------------------------------------------------------
 * adjustDatesToLocal()
 *
 * For any table found in moduleTables, modifies the obj
 * passed by the date fields specified in moduleTables. Each
 * date field's value is converted to localtime from UTC if,
 * in fact, the value can be interpreted as UTC.
 *
 * Note that the obj passed is modified.
 *
 * This function returns true if the table passed was found in
 * the moduleTables object. In other words, it returns true if
 * the table in question was setup properly, even if it has no
 * date fields. The function returns false if the table was not
 * found in moduleTables. The boolean return value does not
 * indicate whether date fields were modified.
 *
 * Rationale:
 * This is necessary because the Bookshelf ORM and the underlying
 * Knex query builder both rely on the MySQL package which
 * returns MySQL DATETIME fields as JS Dates which assumes that
 * the underlying database value is stored as localtime rather
 * than UTC. This behavior can be changed at the connection level,
 * but in the case of this application, there is too much
 * legacy code that relies on the existing behavior to make such
 * a brute force change. In other words, phase one code stored
 * everything as localtime and did not worry about ISO8601 at all,
 * which works for the assumption that Midwife-EMR is used in one
 * locality and not over the Internet.
 *
 * Phase two code, on the other hand, assumes that we want to use
 * ISO8601 throughout the application. The problem is that MySQL
 * itself does not handle ISO8601 or UTC, and combined with the
 * MySQL package defaults (referenced above), it is best to always
 * insert/update into the MySQL database localtimes.
 *
 * Therefore, this function converts dates to localtime just before
 * being applied to the database. The conversion back to ISO8601 is
 * performed by the MySQL package which both Bookshelf and Knex use.
 *
 * References:
 * https://github.com/tgriesser/knex/issues/1461
 * https://github.com/tgriesser/knex/issues/128
 * https://github.com/mysqljs/mysql#connection-options
 *
 * param       table    - string, name of the table
 * param       obj      - object, data to be applied to the db
 * return      boolean  - false if table not found in moduleTables,
 *                        true otherwise
 * -------------------------------------------------------- */
var adjustDatesToLocal = function(table, obj) {
  if (! moduleTables[table]) return false;
  _.each(moduleTables[table], function(fldName) {
    if (obj[fldName] &&
        typeof obj[fldName] === 'string' &&
        moment(obj[fldName]).isValid() ) {
      obj[fldName] = moment(obj[fldName]).local().format('YYYY-MM-DDTHH:mm:ss');
    }
  });
  return true;
}


var addTable = function(data, userInfo, cb, modelObj, tableStr) {
  var rec = data;

  if (! adjustDatesToLocal(tableStr, data)) {
    logError('ERROR: adjustDatesToLocal() returned false for table ' + tableStr);
    logError('ERROR: It looks like the moduleTables data structure has not been setup properly.');
  }

  modelObj.forge(rec)
    .setUpdatedBy(userInfo.user.id)
    .setSupervisor(userInfo.user.supervisor)
    .save({}, {method: 'insert'})
    .then(function(rec2) {
      cb(null, true, rec2);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: tableStr,
        id: rec2.id,
        updatedBy: userInfo.user.id,
        sessionID: userInfo.sessionID
      };
      return sendData(DATA_ADD, JSON.stringify(notify));
    })
    .caught(function(err) {
      return cb(err);
    });
};

var updateTable = function(data, userInfo, cb, modelObj, tableStr) {
  var rec = data;

  if (! adjustDatesToLocal(tableStr, data)) {
    logError('ERROR: adjustDatesToLocal() returned false for table ' + tableStr);
    logError('ERROR: It looks like the moduleTables data structure has not been setup properly.');
  }

  modelObj.forge(rec)
    .setUpdatedBy(userInfo.user.id)
    .setSupervisor(userInfo.user.supervisor)
    .save({}, {method: 'update'})
    .then(function(rec2) {
      cb(null, true, rec2);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: tableStr,
        id: rec2.id,
        updatedBy: userInfo.user.id,
        sessionID: userInfo.sessionID
      };
      return sendData(DATA_CHANGE, JSON.stringify(notify));
    })
    .caught(function(err) {
      return cb(err);
    });
};


/* --------------------------------------------------------
 * addLabor()
 *
 * Add a new labor record.
 *
 * partof: #SPC-dates-server
 * -------------------------------------------------------- */
var addLabor = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLabor(data, cb);
  addTable(data, userInfo, cb, Labor, 'labor');
};

var addLaborStage1 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLaborStage1(data, cb);
  addTable(data, userInfo, cb, LaborStage1, 'laborStage1');
};

var updateLaborStage1 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateLaborStage1(data, cb);
  updateTable(data, userInfo, cb, LaborStage1, 'laborStage1');
};

var notDefinedYet = function(data, userInfo, cb) {
  var msg = 'WARNING: notDefinedYet() called in "routes/comm/labor.js"';
  console.log(msg);
  throw new Error(msg);
};

// --------------------------------------------------------
// Remember to setup moduleTables for each add or update.
// --------------------------------------------------------
module.exports = {
  addLabor,
  delLabor: notDefinedYet,
  updateLabor: notDefinedYet,
  addLaborStage1,
  delLaborStage1: notDefinedYet,
  updateLaborStage1: updateLaborStage1
};

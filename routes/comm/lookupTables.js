/* 
 * -------------------------------------------------------------------------------
 * lookupTables.js
 *
 * Management of various lookup tables.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , MedicationType = require('../../models').MedicationType
  , User = require('../../models').User
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , DATA_ADD = require('../../commUtils').getConstants('DATA_ADD')
  , DATA_CHANGE = require('../../commUtils').getConstants('DATA_CHANGE')
  , DATA_DELETE = require('../../commUtils').getConstants('DATA_DELETE')
  , sendData = require('../../commUtils').sendData
  , assertModule = require('./lookupTables_assert')
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
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
 * param       table        - the table name
 * param       id           - the id of the record sought
 * param       pregnancy_id - limit by pregnancy_id, if applicable
 * param       patient_id   - limit by patient_id, if applicable
 * param       cb
 * -------------------------------------------------------- */
var getLookupTable = function(table, id, pregnancy_id, patient_id, cb) {
  if (DO_ASSERT) assertModule.getLookupTable(table, id, pregnancy_id, patient_id, cb);
  var data = []
    , knex = Bookshelf.DB.knex
    , msg
    , whereObj = {}
    ;

  // --------------------------------------------------------
  // Make sure that the table passed is allowed.
  // --------------------------------------------------------
  if (! _.contains(LOOKUP_TABLES, table)) {
    msg = 'lookupTables.getLookupTable(): ' + table + ' is not an allowed table.';
    return cb(msg);
  }

  // --------------------------------------------------------
  // Construct the where clause.
  // --------------------------------------------------------
  if (id !== -1) whereObj.id = id;
  if (pregnancy_id !== -1) whereObj.pregnancy_id = pregnancy_id;
  if (patient_id !== -1) whereObj.patient_id = patient_id;

  knex(table)
    .select()
    .where(whereObj)
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

var updateMedicationType = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['stateId'];

  MedicationType.forge({id: rec.id})
    .fetch().then(function(medicationType) {
      medicationType
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(_.omit(rec, omitFlds))
        .then(function(rec2) {
          cb(null, true, rec2.id);

          // --------------------------------------------------------
          // Notify all clients of the change.
          // --------------------------------------------------------
          var notify = {
            table: 'medicationType',
            id: rec2.id,
            updatedBy: userInfo.user.id,
            sessionID: userInfo.sessionID
          };
          return sendData(DATA_CHANGE, JSON.stringify(notify));
        })
        .caught(function(err) {
          return cb(err);
        });
    });
};

var addMedicationType = function(data, userInfo, cb) {
  var rec = _.omit(data, ['id', 'pendingId']);

  MedicationType.forge(rec)
    .setUpdatedBy(userInfo.user.id)
    .setSupervisor(userInfo.user.supervisor)
    .save({}, {method: 'insert'})
    .then(function(rec2) {
      cb(null, true, rec2);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: 'medicationType',
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

var delMedicationType = function(data, userInfo, cb) {
  var rec = _.omit(data, ['stateId']);

  new MedicationType({id: rec.id})
    .destroy()
    .then(function(deletedRec) {
      cb(null, true);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: 'medicationType',
        id: rec.id,
        updatedBy: userInfo.user.id,
        sessionID: userInfo.sessionID
      };
      return sendData(DATA_DELETE, JSON.stringify(notify));
    })
    .caught(function(err) {
      return cb(err);
    });
};

module.exports = {
  getLookupTable,
  addMedicationType,
  updateMedicationType,
  delMedicationType
};


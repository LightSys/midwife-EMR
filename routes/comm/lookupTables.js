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
  , KeyValue = require('../../models').KeyValue
  , Apgar = require('../../models').Apgar
  , ContPostpartumCheck = require('../../models').ContPostpartumCheck
  , Labor = require('../../models').Labor
  , LaborStage1 = require('../../models').LaborStage1
  , LaborStage2 = require('../../models').LaborStage2
  , LabSuite = require('../../models').LabSuite
  , LabTest = require('../../models').LabTest
  , LabTestValue = require('../../models').LabTestValue
  , MedicationType = require('../../models').MedicationType
  , Membrane = require('../../models').Membrane
  , NewbornExam = require('../../models').NewbornExam
  , SelectData = require('../../models').SelectData
  , VaccinationType = require('../../models').VaccinationType
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
  , KEY_VALUE_UPDATE = require('../../constants').KEY_VALUE_UPDATE
  , DO_ASSERT = process.env.NODE_ENV? process.env.NODE_ENV === 'development': false
  ;


// --------------------------------------------------------
// These are the lookup tables that we service.
// --------------------------------------------------------
var LOOKUP_TABLES = [
  'apgar',
  'baby',
  'contPostpartumCheck',
  'eventType',
  'labor',
  'laborStage1',
  'laborStage2',
  'laborStage3',
  'labSuite',
  'labTest',
  'labTestValue',
  'medicationType',
  'membrane',
  'newbornExam',
  'patient',
  'pregnancy',
  'pregnoteType',
  'riskCode',
  'role',
  'user',
  'vaccinationType'
];

// --------------------------------------------------------
// These are more lookup tables that do not have pregnancy_id
// or patient_id fields.
// --------------------------------------------------------
var LOOKUP_TABLES_NON_PATIENT = [
  'keyValue',
  'selectData'
];


/* --------------------------------------------------------
 * getTable2()
 *
 * Return the records requested per version 2 of the
 * sub-protocol.
 *
 * param      table
 * param      id
 * param      related
 * param      cb
 * -------------------------------------------------------- */
var getTable2 = function(table, id, related, cb) {
  if (DO_ASSERT) assertModule.getTable2(table, id, related, cb);
  var data = []
    , whereObj = {}
    , relatedInProcess = 0
    , msg
    ;

  // --------------------------------------------------------
  // Make sure that the table passed is allowed.
  // --------------------------------------------------------
  if ((! _.contains(LOOKUP_TABLES, table)) &&
      (! _.contains(LOOKUP_TABLES_NON_PATIENT, table))) {
    msg = 'lookupTables.getLookupTable(): ' + table + ' is not an allowed table.';
    return cb(msg);
  }

  // --------------------------------------------------------
  // Remove any duplicates and related tables that are not
  // allowed.
  // --------------------------------------------------------
  related = _.intersection(related, _.union(LOOKUP_TABLES, LOOKUP_TABLES_NON_PATIENT));

  // --------------------------------------------------------
  // Get the data for the primary table.
  // --------------------------------------------------------
  getRecords(table, 'id', id, function(err, recs) {
    if (err) return cb(err);
    data.push(buildData(table, recs));

    // --------------------------------------------------------
    // Now get the related tables, if there are any.
    // --------------------------------------------------------
    if (related.length > 0) {
      for (let relatedTbl of related) {

        if (relatedTbl === 'patient' && table === 'pregnancy' && id !== -1) {
          // Handle our convoluted schema discrepancy for one patient record.
          getRecords(relatedTbl, 'id', recs[0].patient_id, function(err, recs) {
            if (err) return cb(err);
            data.push(buildData(relatedTbl, recs));
            relatedInProcess++;

            // Return results if we are done.
            if (relatedInProcess === related.length) return cb(null, data);
          });
        } else {
          // Normal relationships using database naming practices for schema.
          getRecords(relatedTbl, table+'_id', id, function(err, recs) {
            if (err) return cb(err);
            data.push(buildData(relatedTbl, recs));
            relatedInProcess++;

            // Return results if we are done.
            if (relatedInProcess === related.length) return cb(null, data);
          });
        }
      }
    } else {
      // No related tables.
      return cb(null, data);
    }
  });
}

/* --------------------------------------------------------
 * buildData()
 *
 * Wrap the data for a version 2 record in the expected format.
 * -------------------------------------------------------- */
function buildData(table, records) {
  return {table: table, records: records};
}

/* --------------------------------------------------------
 * getRecords()
 *
 * Retrieves the data for getTable2() for the table
 * specified.
 * -------------------------------------------------------- */
function getRecords(table, key, value, cb) {
  var data = []
    , knex = Bookshelf.DB.knex
    , whereObj = {}
    ;

  // --------------------------------------------------------
  // Construct the where clause.
  // --------------------------------------------------------
  if (value !== -1) whereObj[key] = value;

  // --------------------------------------------------------
  // We handle some tables as special cases.
  // --------------------------------------------------------
  switch (table) {
    case 'baby':
      // We get the baby records, and then get the corresponding
      // apgar records for each attaching them to an apgarScores field.
      knex('baby')
        .where(whereObj)
        .then(function(babies) {
          var babyIds = _.pluck(babies, 'id');
          knex('apgar')
            .select(['minute', 'score', 'baby_id'])
            .whereIn('baby_id', babyIds)
            .then(function(apgars) {
              // Now match apgars to baby records.
              var results = [];
              _.each(babies, function(baby) {
                var scores = _.filter(apgars, function(a) {return a.baby_id === baby.id;});
                scores = _.map(scores, function(s) {
                  delete s.baby_id;
                  return s;
                });
                baby.apgarScores = scores;
                results.push(baby);
              })

              return cb(null, results);
            })
        })
        .catch(function(err) {
          logError(err);
          return cb(err);
        });
      break;

    default:
      // Normal table retrieval.
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
}


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
  if ((! _.contains(LOOKUP_TABLES, table)) &&
      (! _.contains(LOOKUP_TABLES_NON_PATIENT, table))) {
    msg = 'lookupTables.getLookupTable(): ' + table + ' is not an allowed table.';
    return cb(msg);
  }

  // --------------------------------------------------------
  // Construct the where clause, but only for tables that have
  // those fields.
  // --------------------------------------------------------
  if (id !== -1) whereObj.id = id;
  if (! _.contains(LOOKUP_TABLES_NON_PATIENT, table)) {
    if (pregnancy_id !== -1) whereObj.pregnancy_id = pregnancy_id;
    if (patient_id !== -1) whereObj.patient_id = patient_id;
  }

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

/* --------------------------------------------------------
 * setSelectDataSingleDefault()
 *
 * Makes sure that at most 1 record in a selectData group
 * by name is set as default. Takes the id of the record
 * that is to be the default for all of the records with the
 * same name.
 *
 * Note that it is allowed that there are no default records
 * in a group.
 * -------------------------------------------------------- */
var setSelectDataSingleDefault = function(id) {
  var knex = Bookshelf.DB.knex
    , name = void 0
    ;

  SelectData.forge({id: id})
    .fetch()
    .then(function(rec) {
      name = rec.get('name');

      return knex('selectData')
        .where({name: name})
        .whereNot({id: id})
        .update({selected: 0});
    });
};

/* --------------------------------------------------------
 * setSelectDataNoDefaultByName()
 *
 * Makes sure that zero records in a selectData group
 * by name are set as default. Takes the name of the records
 * to set all selected fields to false. This allows a subsequent
 * operation that adds a record with the same name and a
 * the selected field set to true to be the default record
 * for that name group.
 *
 * Note that it is allowed that there are no default records
 * in a group.
 * -------------------------------------------------------- */
var setSelectDataNoDefaultByName = function(name, cb) {
  var knex = Bookshelf.DB.knex
    ;

  knex('selectData')
    .where({name: name})
    .update({selected: 0})
    .then(function() {
      return cb(null);
    });
};

var addTable = function(data, userInfo, cb, modelObj, tableStr) {
  var rec = _.omit(data, ['id', 'pendingId']);

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

var delTable = function(data, userInfo, cb, modelObj, tableStr) {
  var rec = _.omit(data, ['stateId']);

  new modelObj({id: rec.id})
    .destroy()
    .then(function(deletedRec) {
      cb(null, true);

      // --------------------------------------------------------
      // Notify all clients of the change.
      // --------------------------------------------------------
      var notify = {
        table: tableStr,
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

var updateTable = function(data, userInfo, cb, modelObj, tableStr) {
  var rec = data;
  var omitFlds = ['stateId'];

  modelObj.forge({id: rec.id})
    .fetch().then(function(table) {
      table
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(_.omit(rec, omitFlds))
        .then(function(rec2) {
          cb(null, true, rec2.id);

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
    });
};

// --------------------------------------------------------
// We only allow updates to the keyValue table and even at
// that, we only allow the kvValue field to be modified.
// --------------------------------------------------------
var updateKeyValue = function(data, userInfo, cb) {
  updateTable(_.pick(data, ['id', 'kvValue']), userInfo, function(err, success, data) {
    // Inform all processes of the change.
    if (process.send) {
      // Get all of the latest keyValue data, not just what was updated.
      KeyValue.getKeyValues().then(function(data) {
        var msg = {};
        msg[KEY_VALUE_UPDATE] = data;
        process.send(msg);
      })
      .caught(function(err) {
        logError(err);
      })
      .finally(function() {
        return cb(err, success, data);
      });
    }
  } , KeyValue, 'keyValue');
};

var addLabSuite = function(data, userInfo, cb) {
  addTable(data, userInfo, cb, LabSuite, 'labSuite');
};

var delLabSuite = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, LabSuite, 'labSuite');
};

var updateLabSuite = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, LabSuite, 'labSuite');
};

var addLabTest = function(data, userInfo, cb) {
  addTable(data, userInfo, cb, LabTest, 'labTest');
};

var delLabTest = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, LabTest, 'labTest');
};

var updateLabTest = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, LabTest, 'labTest');
};

var addLabTestValue = function(data, userInfo, cb) {
  addTable(data, userInfo, cb, LabTestValue, 'labTestValue');
};

var delLabTestValue = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, LabTestValue, 'labTestValue');
};

var updateLabTestValue = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, LabTestValue, 'labTestValue');
};

var addMedicationType = function(data, userInfo, cb) {
  addTable(data, userInfo, cb, MedicationType, 'medicationType');
};

var delMedicationType = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, MedicationType, 'medicationType');
};

var updateMedicationType = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, MedicationType, 'medicationType');
};

var addSelectData = function(data, userInfo, cb) {
  // Insure that at most one record in a group by name,
  // and since this additional record wants to be the
  // default selected record, first set all other
  // records in the name group to not be selected.
  if (data.selected) {
    setSelectDataNoDefaultByName(data.name, function() {
      addTable(data, userInfo, cb, SelectData, 'selectData');
    });
  } else {
    addTable(data, userInfo, cb, SelectData, 'selectData');
  }
};

var delSelectData = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, SelectData, 'selectData');
};

var updateSelectData = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, SelectData, 'selectData');

  // Insure that at most one record in a group by name
  // is the default record. Zero default records are allowed.
  if (data.selected) {
    setSelectDataSingleDefault(data.id);
  }
};

var addVaccinationType = function(data, userInfo, cb) {
  addTable(data, userInfo, cb, VaccinationType, 'vaccinationType');
};

var delVaccinationType = function(data, userInfo, cb) {
  delTable(data, userInfo, cb, VaccinationType, 'vaccinationType');
};

var updateVaccinationType = function(data, userInfo, cb) {
  updateTable(data, userInfo, cb, VaccinationType, 'vaccinationType');
};

// --------------------------------------------------------
// Note: the add, update, and delete functions below are for
// tables managed by the administrator role and not directly
// regarding patient data.
//
// The lookup tables functions are used by the admin and
// patient management roles.
// --------------------------------------------------------
module.exports = {
  getLookupTable,
  getTable2,
  addLabSuite,
  addLabTest,
  addLabTestValue,
  addMedicationType,
  addSelectData,
  addVaccinationType,
  delLabSuite,
  delLabTest,
  delLabTestValue,
  delMedicationType,
  delSelectData,
  delVaccinationType,
  updateKeyValue,
  updateLabSuite,
  updateLabTest,
  updateLabTestValue,
  updateMedicationType,
  updateSelectData,
  updateVaccinationType
};


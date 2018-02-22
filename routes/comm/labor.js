/*
 * -------------------------------------------------------------------------------
 * labor.js
 *
 * Data management routines for the labor, delivery, and postpartum tables.
 * -------------------------------------------------------------------------------
 */


var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , Apgar = require('../../models').Apgar
  , Baby = require('../../models').Baby
  , BabyMedication = require('../../models').BabyMedication
  , BabyLab = require('../../models').BabyLab
  , BabyVaccination = require('../../models').BabyVaccination
  , ContPostpartumCheck = require('../../models').ContPostpartumCheck
  , Labor = require('../../models').Labor
  , LaborStage1 = require('../../models').LaborStage1
  , LaborStage2 = require('../../models').LaborStage2
  , LaborStage3 = require('../../models').LaborStage3
  , Membrane = require('../../models').Membrane
  , NewbornExam = require('../../models').NewbornExam
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
moduleTables.apgar = [];
moduleTables.baby = ['bFedEstablished' ];
moduleTables.babyMedication = ['medicationDate'];
moduleTables.babyLab = ['dateTime'];
moduleTables.babyVaccination = ['vaccinationDate'];
moduleTables.contPostpartumCheck = ['checkDatetime'];
moduleTables.labor = ['admittanceDate', 'startLaborDate', 'dischargeDate'];
moduleTables.laborStage1 = ['fullDialation'];
moduleTables.laborStage2 = ['birthDatetime'];
moduleTables.laborStage3 = ['placentaDatetime'];
moduleTables.membrane = ['ruptureDatetime'];
moduleTables.newbornExam = ['examDatetime'];

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


// --------------------------------------------------------
// For baby records, the client will include a field named
// apgarScores in the baby record. This will be used to
// populate the apgar table accordingly.
// --------------------------------------------------------
var addBaby = function(data, userInfo, cb) {
  var knex = Bookshelf.DB.knex
    , babyId
    ;

  if (DO_ASSERT) assertModule.addBaby(data, cb);

  knex.transaction(function(t) {
    return knex('baby')
      .transacting(t)
      .insert({
        birthNbr: data.birthNbr,
        lastname: data.lastname,
        firstname: data.firstname,
        middlename: data.middlename,
        sex: data.sex,
        birthWeight: data.birthWeight,
        bFedEstablished: data.bFedEstablished,
        bulb: data.bulb,
        machine: data.machine,
        freeFlowO2: data.freeFlowO2,
        chestCompressions: data.chestCompressions,
        ppv: data.ppv,
        comments: data.comments,
        updatedBy: userInfo.user.id,
        updatedAt: knex.fn.now(),
        supervisor: userInfo.user.supervisor,
        labor_id: data.labor_id
      })
      .then(function(bbId) {
        var recsToInsert = []
          ;

        // bbId is an array.
        if (bbId.length > 0) {
          babyId = bbId[0];

          if (data.apgarScores.length > 0) {
            _.each(data.apgarScores, function(rec) {
              rec.baby_id = babyId;
              rec.updatedBy = userInfo.user.id;
              rec.updatedAt = new Date();
              rec.supervisor = userInfo.user.supervisor;
              recsToInsert.push(rec);
            });

            return knex('apgar')
              .transacting(t)
              .insert(recsToInsert)
              .then(function(idsInserted) {
                // In MySQL, only the first inserted id is returned.
                if (idsInserted.lenth > 0) {
                  logInfo('Inserted one or more rows into apgar.');
                }
              });
          }
        } else {
          return true;
        }
      })
      .then(t.commit)
      .then(function() {
        data.id = babyId;
        cb(null, true, data);

        // --------------------------------------------------------
        // Notify all clients of the change.
        // --------------------------------------------------------
        var notify = {
          table: 'baby',
          id: babyId,
          updatedBy: userInfo.user.id,
          sessionID: userInfo.sessionID
        };
        return sendData(DATA_ADD, JSON.stringify(notify));
      })
      .catch(t.rollback);
  });
};

var updateBaby = function(data, userInfo, cb) {
  var knex = Bookshelf.DB.knex
    ;

  if (DO_ASSERT) assertModule.updateBaby(data, cb);

  knex.transaction(function(t) {
    return knex('baby')
      .transacting(t)
      .where('id', data.id)
      .update({
        birthNbr: data.birthNbr,
        lastname: data.lastname,
        firstname: data.firstname,
        middlename: data.middlename,
        sex: data.sex,
        birthWeight: data.birthWeight,
        bFedEstablished: data.bFedEstablished,
        bulb: data.bulb,
        machine: data.machine,
        freeFlowO2: data.freeFlowO2,
        chestCompressions: data.chestCompressions,
        ppv: data.ppv,
        comments: data.comments,
        updatedBy: userInfo.user.id,
        updatedAt: knex.fn.now(),
        supervisor: userInfo.user.supervisor,
        labor_id: data.labor_id
      })
      .then(function(numRows) {
        // Apgar records: the data.apgarScores represents the truth and the
        // apgar table records need to be adjusted accordingly.
        return knex('apgar')
          .where('baby_id', data.id)
          .select(['id', 'minute', 'score'])
          .transacting(t)
          .then(function(currApgars) {
            var insertPromise = [] // Default if never used.
              , deletePromise = [] // Default if never used.
              , updatePromises = []
              , idsToDelete = []
              , recsToInsert = []
              , recsToUpdate = []
              ;

            // --------------------------------------------------------
            // Identify the records to delete: if a particular minute
            // in the current set of apgars is not found in the new
            // set of apgars, we delete that record using the id.
            // --------------------------------------------------------
            _.each(currApgars, function(currApgar) {
              if (! _.find(data.apgarScores, function(a) {return a.minute === currApgar.minute;})) {
                idsToDelete.push(currApgar.id);
              }
            });

            _.each(data.apgarScores, function(newApgar) {
              // --------------------------------------------------------
              // Identify the records to add: if a particular minute in
              // the new set of apgars is not found in the current set
              // of apgars, we add that record using minute and score.
              // --------------------------------------------------------
              if (! _.some(currApgars, function(a) {return a.minute === newApgar.minute;})) {
                newApgar.baby_id = data.id;
                newApgar.updatedBy = userInfo.user.id;
                newApgar.updatedAt = new Date();
                newApgar.supervisor = userInfo.user.supervisor;
                recsToInsert.push(newApgar);
              }

              // --------------------------------------------------------
              // Identify the records to change: if a particular minute
              // exists in both the new set of apgars and the current set
              // of apgars, but the score is different, then update the
              // score accordingly.
              // --------------------------------------------------------
              var match = _.find(currApgars, function(a) {return a.minute === newApgar.minute;});
              if (match && match.score !== newApgar.score) {
                match.baby_id = data.id;
                match.score = newApgar.score;
                match.updatedBy = userInfo.user.id;
                match.updatedAt = new Date();
                match.supervisor = userInfo.user.supervisor;
                recsToUpdate.push(match);
              }
            });

            if (recsToInsert.length > 0) {
              insertPromise = knex('apgar')
                .transacting(t)
                .insert(recsToInsert)
                .then(function(idsInserted) {
                  // In MySQL, only the first inserted id is returned.
                  if (idsInserted.lenth > 0) {
                    logInfo('Inserted one or more rows into apgar.');
                  }
                });
            }

            if (idsToDelete.length > 0) {
              deletePromise = knex('apgar')
                .transacting(t)
                .whereIn('id', idsToDelete)
                .del()
                .then(function(numRows) {
                  logInfo('Deleted ' + numRows + ' apgar rows.');
                });
            }

            if (recsToUpdate.length > 0) {
              _.each(recsToUpdate, function(rec) {
                console.log(rec);
                var updPromise = knex('apgar')
                  .transacting(t)
                  .where('id', rec.id)
                  .update(rec)
                  .then(function() {
                    logInfo('Updated apgar, id: ' + rec.id + '.');
                  });
                updatePromises.push(updPromise);
              });
            }

            return Promise.all(_.flatten([insertPromise, deletePromise, updatePromises]))
              .then(function() {
                return true;
              });
         });
      })
      .then(t.commit)
      .then(function() {
        cb(null, true, data);

        // --------------------------------------------------------
        // Notify all clients of the change.
        // --------------------------------------------------------
        var notify = {
          table: 'baby',
          id: data.id,
          updatedBy: userInfo.user.id,
          sessionID: userInfo.sessionID
        };
        return sendData(DATA_CHANGE, JSON.stringify(notify));
      })
      .catch(t.rollback);
  });
};

var addBabyLab = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addBabyLab(data, cb);
  addTable(data, userInfo, cb, BabyLab, 'babyLab');
};

var updateBabyLab = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateBabyLab(data, cb);
  updateTable(data, userInfo, cb, BabyLab, 'babyLab');
};

var addBabyMedication = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addBabyMedication(data, cb);
  addTable(data, userInfo, cb, BabyMedication, 'babyMedication');
};

var updateBabyMedication = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateBabyMedication(data, cb);
  updateTable(data, userInfo, cb, BabyMedication, 'babyMedication');
};

var addBabyVaccination = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addBabyVaccination(data, cb);
  addTable(data, userInfo, cb, BabyVaccination, 'babyVaccination');
};

var updateBabyVaccination = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateBabyVaccination(data, cb);
  updateTable(data, userInfo, cb, BabyVaccination, 'babyVaccination');
};

var addContPostpartumCheck = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addContPostpartumCheck(data, cb);
  addTable(data, userInfo, cb, ContPostpartumCheck, 'contPostpartumCheck');
};

var updateContPostpartumCheck = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateContPostpartumCheck(data, cb);
  updateTable(data, userInfo, cb, ContPostpartumCheck, 'contPostpartumCheck');
};

var addLabor = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLabor(data, cb);
  addTable(data, userInfo, cb, Labor, 'labor');
};

var updateLabor = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateLabor(data, cb);
  updateTable(data, userInfo, cb, Labor, 'labor');
};

var addLaborStage1 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLaborStage1(data, cb);
  addTable(data, userInfo, cb, LaborStage1, 'laborStage1');
};

var updateLaborStage1 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateLaborStage1(data, cb);
  updateTable(data, userInfo, cb, LaborStage1, 'laborStage1');
};

var addLaborStage2 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLaborStage2(data, cb);
  addTable(data, userInfo, cb, LaborStage2, 'laborStage2');
};

var updateLaborStage2 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateLaborStage2(data, cb);
  updateTable(data, userInfo, cb, LaborStage2, 'laborStage2');
};

var addLaborStage3 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addLaborStage3(data, cb);
  addTable(data, userInfo, cb, LaborStage3, 'laborStage3');
};

var updateLaborStage3 = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateLaborStage3(data, cb);
  updateTable(data, userInfo, cb, LaborStage3, 'laborStage3');
};

var addMembrane = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addMembrane(data, cb);
  addTable(data, userInfo, cb, Membrane, 'membrane');
};

var updateMembrane = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateMembrane(data, cb);
  updateTable(data, userInfo, cb, Membrane, 'membrane');
};

var addNewbornExam = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.addNewbornExam(data, cb);
  addTable(data, userInfo, cb, NewbornExam, 'newbornExam');
};

var updateNewbornExam = function(data, userInfo, cb) {
  if (DO_ASSERT) assertModule.updateNewbornExam(data, cb);
  updateTable(data, userInfo, cb, NewbornExam, 'newbornExam');
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
  addBaby,
  updateBaby,
  delBaby: notDefinedYet,
  addBabyLab,
  updateBabyLab,
  delBabyLab: notDefinedYet,
  addBabyMedication,
  updateBabyMedication,
  delBabyMedication: notDefinedYet,
  addBabyVaccination,
  updateBabyVaccination,
  delBabyVaccination: notDefinedYet,
  addContPostpartumCheck,
  updateContPostpartumCheck,
  delContPostpartumCheck: notDefinedYet,
  addLabor,
  delLabor: notDefinedYet,
  updateLabor,
  addLaborStage1,
  delLaborStage1: notDefinedYet,
  updateLaborStage1: updateLaborStage1,
  addLaborStage2,
  delLaborStage2: notDefinedYet,
  updateLaborStage2,
  addLaborStage3,
  delLaborStage3: notDefinedYet,
  updateLaborStage3,
  addMembrane,
  updateMembrane,
  delMembrane: notDefinedYet,
  addNewbornExam,
  updateNewbornExam,
  delNewbornExam : notDefinedYet
};

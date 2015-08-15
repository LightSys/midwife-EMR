/* --------------------------------------------------------
 * history.js
 *
 * "REST"-like api for client calls. Data is read-only so
 * certain standard REST calls do not apply.
 * -------------------------------------------------------- */
var cfg = require('../../config')
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , _ = require('underscore-contrib')
  ;


/* --------------------------------------------------------
 * getAllData()
 *
 * Returns all of the historical data for a specific patient
 * to the caller in one JSON data structure.
 * -------------------------------------------------------- */
var getAllData = function(req, res) {
  var sqlPreg
    , sqlPat
    , sqlRisk
    , sqlPreExam
    , sqlPregHist
    , sqlReferral
    , sqlMed
    , sqlVac
    , sqlHealth
    , sqlLabTestResult
    , sqlSchedule
    , sqlCustomField
    , sqlUser
    , sqlVacType
    , sqlMedType
    , sqlCustomFieldType
    , start = Date.now()
    , end
    ;

  if (req.parameters && req.parameters.id1) {
    pregId = req.parameters.id1;
  } else {
    // Bad request since the proper parameter not specified.
    res.statusCode = 400;
    return res.end();
  }

  // PregnancyLog
  sqlPreg = 'SELECT * FROM pregnancyLog WHERE id = ? ORDER BY replacedAt';

  // PatientLog
  sqlPat  = 'SELECT pa.* FROM patientLog pa INNER JOIN pregnancy pr ';
  sqlPat += 'ON pr.patient_id = pa.id WHERE pr.id = ? ORDER BY pa.replacedAt';

  // riskLog
  sqlRisk =  'SELECT rl.*, rc.name, rc.riskType, rc.description FROM riskLog rl ';
  sqlRisk += 'INNER JOIN riskCode rc ON rl.riskCode = rc.id WHERE pregnancy_id = ? ';
  sqlRisk += 'ORDER BY replacedAt';

  // prenatalExamLog
  sqlPreExam =  'SELECT * FROM prenatalExamLog WHERE pregnancy_id = ?';

  // medicationLog
  sqlMed =  'SELECT * FROM medicationLog WHERE pregnancy_id = ?';

  // vaccinationLog
  sqlVac =  'SELECT * FROM vaccinationLog WHERE pregnancy_id = ?';

  // pregnancyHistoryLog
  sqlPregHist = 'SELECT * FROM pregnancyHistoryLog WHERE pregnancy_id = ?';

  // referralLog
  sqlReferral = 'SELECT * FROM referralLog WHERE pregnancy_id = ?';

  // healthTeachingLog
  sqlHealth = 'SELECT * FROM healthTeachingLog WHERE pregnancy_id = ?';

  // pregnoteLog
  // NOTE: there is no pregnoteLog table.
  //sqlPregNote = 'SELECT * FROM pregnoteLog WHERE pregnancy_id = ?';

  // labTestResultLog
  sqlLabTestResult = 'SELECT * FROM labTestResultLog WHERE pregnancy_id = ?';

  // scheduleLog
  sqlSchedule = 'SELECT * FROM scheduleLog WHERE pregnancy_id = ?';

  // customFieldLog
  sqlCustomField = 'SELECT * FROM customFieldLog WHERE pregnancy_id = ?';

  // --------------------------------------------------------
  // Lookup Tables. These do not reference Log tables nor
  // need to reference pregnancy id.
  // --------------------------------------------------------
  sqlUser =  'SELECT u.id, u.username, u.firstname, u.lastname, u.shortName, ';
  sqlUser += 'u.displayName, u.status, u.isCurrentTeacher, r.name AS rolename ';
  sqlUser += 'FROM user u INNER JOIN user_role ur ON u.id = ur.user_id ';
  sqlUser += 'INNER JOIN role r ON ur.role_id = r.id';

  sqlVacType =  'SELECT * FROM vaccinationType';

  sqlMedType =  'SELECT * FROM medicationType';

  sqlCustomFieldType = 'SELECT * FROM customFieldType';

  return Promise.all([
    // main Log tables
    getData(sqlPreg, 'pregnancy', pregId),
    getData(sqlPat, 'patient', pregId),
    // Secondary Log tables
    getData(sqlRisk, 'risk', pregId),
    getData(sqlPreExam, 'prenatalExam', pregId),
    getData(sqlMed, 'medication', pregId),
    getData(sqlVac, 'vaccination', pregId),
    getData(sqlPregHist, 'pregnancyHistory', pregId),
    getData(sqlReferral, 'referral', pregId),
    getData(sqlHealth, 'healthTeaching', pregId),
    getData(sqlLabTestResult, 'labTestResult', pregId),
    getData(sqlSchedule, 'schedule', pregId),
    getData(sqlCustomField, 'customField', pregId),
    // Lookup tables
    getData(sqlUser, 'user'),
    getData(sqlVacType, 'vaccinationType'),
    getData(sqlMedType, 'medicationType'),
    getData(sqlCustomFieldType, 'customFieldType'),
  ]).then(function(results) {
    // --------------------------------------------------------
    // The Angular client expects an array. The first record
    // of the array will be the collated/merged main tables.
    // --------------------------------------------------------
    var data = [];
    var main = {};
    var lookup = {};
    var changeMap;
    var changeLogSources;

    // --------------------------------------------------------
    // The *Log tables are provided to the client raw as the first
    // record of the array. These are all *Log tables but they are
    // also being saved to their non-Log names so that the client
    // can leverage the same templates, etc. for historical and
    // non-historical views.
    // --------------------------------------------------------
    _.map(['patient', 'pregnancy', 'risk', 'prenatalExam', 'medication',
           'vaccination', 'pregnancyHistory', 'referral', 'healthTeaching',
           'labTestResult', 'schedule', 'customField'], function(src) {
      // Find the array, drop the leading source name, and assign the inner array.
      main[src] = _.find(results, function(a) {return a[0] === src;}).slice(1)[0];
    });
    data.push(main);

    // --------------------------------------------------------
    // Lookup tables. Lookup tables are not keyed to a particular
    // pregnancy id.
    //
    // Add more lookup tables to the input array as the come online.
    // --------------------------------------------------------
    _.map(['user', 'vaccinationType', 'medicationType', 'customFieldType'], function(src) {
      // Find the array, drop the leading source name, and assign the inner array.
      lookup[src] = _.find(results, function(a) {return a[0] === src;}).slice(1)[0];
    });
    data.push(lookup);

    // --------------------------------------------------------
    // High-level change log for ease of client use. This allows
    // the client to quickly discern which fields have changed
    // at the table level while progressing through historical
    // changes.
    // --------------------------------------------------------
    changeLogSources = ['pregnancy', 'patient', 'risk', 'prenatalExam',
                        'medication', 'vaccination', 'pregnancyHistory',
                        'referral', 'healthTeaching', 'labTestResult',
                        'schedule', 'customField'];
    changeLog = generateChangeLog(results, changeLogSources);
    data.push(changeLog);

    logInfo('Data query response time: ' + (Date.now() - start) + ' ms.');
    res.end(JSON.stringify(data));
  });
};

/* --------------------------------------------------------
 * generateChangeLog()
 *
 * Create an array of meta information about historical
 * changes sorted by the replacedAt field across all data
 * sources. This will allow the client to more easily
 * ascertain significant changes per whatever criteria
 * is desired.
 *
 * param      data - the historical data sources
 * param      sources - array of source names to find in data
 * return     changeLog - an array of meta information
 * -------------------------------------------------------- */
var generateChangeLog = function(data, sources) {
  var changeLog = [];
  var mergeLog = [];
  var newRec = {};
  var indexes = {};
  var cnt = 0;
  // We don't report on changes in these fields because they
  // always change no matter what.
  var excludedKeys = ['replacedAt', 'updatedAt', 'updatedBy'];

  // --------------------------------------------------------
  // For each data source, i.e. tables: patient, pregnancy, etc.
  // --------------------------------------------------------
  _.each(data, function(src) {
    var srcName = src[0];
    var lastRec;

    // Only process the sources we are interested in.
    if (_.indexOf(sources, srcName) !== -1) {

      // TODO: consider adding more meta information.

      // --------------------------------------------------------
      // For each of the historical records within a data source.
      // --------------------------------------------------------
      _.each(src[1], function(rec, idx) {
        var flds = [];
        chgLogOjb = {};
        cnt++;
        if (! lastRec) {
          // First record.
          flds = _.keys(_.omit(rec, excludedKeys));
          chgLogObj = {
            source: srcName,
            id: rec.id,
            replacedAt: rec.replacedAt,
            fields: flds,
            idx: idx};
          if (rec.pregnancy_id) chgLogObj.pregnancy_id = rec.pregnancy_id;  // Detail tables
          changeLog.push(chgLogObj);
          lastRec = rec;
        } else {
          if (rec.id && lastRec.id && rec.id !== lastRec.id) {
            // First record of a different id in a detail table (one to many).
            flds = _.keys(_.omit(rec, excludedKeys));
            chgLogObj = {
              source: srcName,
              id: rec.id,
              replacedAt: rec.replacedAt,
              fields: flds,
              idx: idx};
            if (rec.pregnancy_id) chgLogObj.pregnancy_id = rec.pregnancy_id;  // Detail tables
            changeLog.push(chgLogObj);
            lastRec = rec;
          } else {
            _.each(_.keys(_.omit(rec, excludedKeys)), function(key) {
              if (! _.isEqual(lastRec[key], rec[key])) {
                if (_.indexOf(excludedKeys, key) === -1) {
                  flds.push(key);
                }
              }
            });
            // TODO: if the flds array is empty, should it still be added?
            // Basically this is a database save that actually did not change any data.
            if (flds.length > 0) {
              chgLogObj = {
                source: srcName,
                id: rec.id,
                replacedAt: rec.replacedAt,
                fields: flds,
                idx: idx};
              if (rec.pregnancy_id) chgLogObj.pregnancy_id = rec.pregnancy_id;  // Detail tables
              changeLog.push(chgLogObj);
            }
            lastRec = rec;
          }
        }
      });
    }   // end has sources
  });   // end outer each

  // --------------------------------------------------------
  // Sort by replacedAt field across all data sources and sort
  // secondarily by record id so that records saved simultaneously
  // are saved in order of id.
  // --------------------------------------------------------
  changeLog.sort(function(a, b) {
    var aa = (a.replacedAt.getTime() * 1000) + a.id;
    var bb = (b.replacedAt.getTime() * 1000) + b.id;
    if (aa < bb) {
      return -1;
    } else if (aa > bb) {
      return 1;
    }
    return 0;
  });

  // --------------------------------------------------------
  // Initialize the indexes of the data sources.
  // --------------------------------------------------------
  _.each(sources, function(s) {indexes[s] = {};});

  // --------------------------------------------------------
  // Merge records with the same replacedAt times into the
  // same record then add indexes to reflect the state of
  // related data sources at that replacedAt time.
  // --------------------------------------------------------
  _.each(changeLog, function(rec, idx) {
    if (idx === 0) {
      // First record.
      newRec.replacedAt = rec.replacedAt;
      newRec[rec.source] = {};
      newRec[rec.source][rec.id] = {
        fields: rec.fields
      };
      indexes[rec.source][rec.id] = rec.idx;
      if (rec.pregnancy_id) {
        if (rec.op === 'D') {
          delete indexes[rec.source][rec.id];
        }
      }
      newRec.indexes = _.snapshot(indexes);
    } else {
      if (newRec.replacedAt.getTime() !== rec.replacedAt.getTime()) {
        // New replacedAt time, so store completed record in mergeLog.
        mergeLog.push(newRec);

        // Start a new record.
        newRec = {};
        newRec.replacedAt = rec.replacedAt;
        newRec[rec.source] = {};
        newRec[rec.source][rec.id] = {
          fields: rec.fields
        };
        indexes[rec.source][rec.id] = rec.idx;
        if (rec.pregnancy_id) {
          if (rec.op === 'D') {
            delete indexes[rec.source][rec.id];
          }
        }
        newRec.indexes = _.snapshot(indexes);
      } else {
        // Multiple data sources with the same replacedAt time
        // so add to the current record.
        if (! newRec[rec.source]) newRec[rec.source] = {};
        newRec[rec.source][rec.id] = {
          fields: rec.fields
        };
        indexes[rec.source][rec.id] = rec.idx;
        if (rec.pregnancy_id) {
          if (rec.op === 'D') {
            delete indexes[rec.source][rec.id];
          }
        }
        newRec.indexes = _.snapshot(indexes);
      }
    }
  });
  // Add the final record.
  mergeLog.push(newRec);

  // Debugging
  //console.log(require('util').inspect(mergeLog, {depth: 4}));

  return mergeLog;
};

/* --------------------------------------------------------
 * getData()
 *
 * Return a promise which will resolve to the data for the
 * specified query. Returns an Array with the srcName as
 * the first element and the results of the query (another
 * array) as the second.
 *
 * param       sql
 * param       srcName
 * param       pregId
 * return      promise
 * -------------------------------------------------------- */
var getData = function(sql, srcName, pregId) {
  var knex
    , sqlRisk
    , results
    ;

  return new Promise(function(resolve, reject) {
    knex = Bookshelf.DB.knex;
    return knex
      .raw(sql, pregId)
      .then(function(data) {
        var results = [];
        results.push(srcName);
        results.push(data[0]);
        return resolve(results);
      });
  });
};

/* --------------------------------------------------------
 * get()
 *
 * Delegates to other functions according to the settings
 * in req.parameters as set by params() upstream.
 * -------------------------------------------------------- */
var get = function(req, res) {
  switch(req.parameters.op2) {
    case 'pregnancy':
      switch(req.parameters.op3) {
        case void 0:
          return getAllData(req, res);
          break;
        default:
          logError('Unsupported API call: ' + req.path);
          res.redirect(cfg.path.search);
      }
    default:
      logError('op2 unknown: ' + req.parameters.op2);
      res.redirect(cfg.path.search);
  }
};

module.exports = {
  get: get
};


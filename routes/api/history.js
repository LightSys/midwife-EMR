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
  , collateRecs = require('../../util').collateRecs
  , mergeRecs = require('../../util').mergeRecs
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , _ = require('underscore')
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
    , sqlUser
    , sqlVacType
    , sqlMedType
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
    // Lookup tables
    getData(sqlUser, 'user'),
    getData(sqlVacType, 'vaccinationType'),
    getData(sqlMedType, 'medicationType'),
  ]).then(function(results) {
    // --------------------------------------------------------
    // The Angular client expects an array. The first record
    // of the array will be the collated/merged main tables.
    // --------------------------------------------------------
    var data = [];
    var main;
    var secondary = {};
    var lookup = {};
    var changeMap;
    var changeLogSources;

    // --------------------------------------------------------
    // The main tables are patient and pregnancy, which are in
    // a master/detail relationship with one another, though
    // for our purposes pregnancy is by far the more important
    // table, hence being grouped with the "main" tables.
    //
    // The main tables which are collated/merged. The "Log"
    // suffix on the table references are removed for the client.
    // --------------------------------------------------------

    // --------------------------------------------------------
    // TODO: Determine if main with the collateRecs() and
    // mergeRecs() from util.js is really needed anymore in
    // light of how historyService.formatData() is using the data.
    // --------------------------------------------------------
    main = _.object(results.slice(0, 1));
    main = collateRecs(main, 'replacedAt');
    mergeRecs(main, 'replacedAt');
    data.push(main);

    // --------------------------------------------------------
    // The secondary tables are basically detail tables to the
    // master pregnancy table.
    //
    // The secondary tables which are provided to the client raw
    // as the second record of the array. These are all *Log
    // tables but they are also being saved to their non-Log names
    // so that the client can leverage the same templates, etc.
    // for historical and non-historical views.
    //
    // Add more secondary tables to the input array as the come online.
    //
    // TODO: see above. Is secondary used instead of main?
    // --------------------------------------------------------
    _.map(['patient', 'pregnancy', 'risk', 'prenatalExam', 'medication',
           'vaccination', 'pregnancyHistory', 'referral', 'healthTeaching',
           'labTestResult'], function(src) {
      // Find the array, drop the leading source name, and assign the inner array.
      secondary[src] = _.find(results, function(a) {return a[0] === src;}).slice(1)[0];
    });
    data.push(secondary);

    // --------------------------------------------------------
    // Lookup tables. Lookup tables are not keyed to a particular
    // pregnancy id.
    //
    // Add more lookup tables to the input array as the come online.
    // --------------------------------------------------------
    _.map(['user', 'vaccinationType', 'medicationType'], function(src) {
      // Find the array, drop the leading source name, and assign the inner array.
      lookup[src] = _.find(results, function(a) {return a[0] === src;}).slice(1)[0];
    });
    data.push(lookup);

    // --------------------------------------------------------
    // High-level change log for ease of client use.
    // --------------------------------------------------------
    changeLogSources = ['pregnancy', 'patient', 'risk', 'prenatalExam',
                        'medication', 'vaccination', 'pregnancyHistory',
                        'referral', 'healthTeaching', 'labTestResult'];
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
        // We don't report on changes in these fields because they
        // always change no matter what.
        var excludedKeys = ['replacedAt', 'updatedAt', 'updatedBy'];
        cnt++;
        if (! lastRec) {
          // First record.
          flds = _.keys(_.omit(rec, excludedKeys));
          changeLog.push({source: srcName, replacedAt: rec.replacedAt,
            fields: flds, idx: idx});
          lastRec = rec;
        } else {
          if (rec.id && lastRec.id && rec.id !== lastRec.id) {
            // First record of a different id in a detail table (one to many).
            flds = _.keys(_.omit(rec, excludedKeys));
            changeLog.push({source: srcName, replacedAt: rec.replacedAt,
              fields: flds, idx: idx});
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
              changeLog.push({source: srcName, replacedAt: rec.replacedAt,
                fields: flds, idx: idx});
            }
            lastRec = rec;
          }
        }
      });
    }   // end has sources
  });   // end outer each

  // --------------------------------------------------------
  // Sort by replacedAt field across all data sources.
  // --------------------------------------------------------
  changeLog.sort(function(a, b) {
    if (a.replacedAt < b.replacedAt) {
      return -1;
    } else if (a.replacedAt > b.replacedAt) {
      return 1;
    }
    return 0;
  });

  // --------------------------------------------------------
  // Initialize the indexes of the data sources.
  // --------------------------------------------------------
  _.each(sources, function(s) {indexes[s] = 0;});

  // --------------------------------------------------------
  // Merge records with the same replacedAt times into the
  // same record.
  // --------------------------------------------------------
  _.each(changeLog, function(rec, idx) {
    if (idx === 0) {
      // First record.
      newRec.replacedAt = rec.replacedAt;
      newRec[rec.source] = {
        fields: rec.fields
      };
      indexes[rec.source] = rec.idx;
      newRec.indexes = _.clone(indexes);
    } else {
      if (newRec.replacedAt.getTime() !== rec.replacedAt.getTime()) {
        // New replacedAt time, so store completed record in mergeLog.
        mergeLog.push(newRec);

        // Start a new record.
        newRec = {};
        newRec.replacedAt = rec.replacedAt;
        newRec[rec.source] = {
          fields: rec.fields
        };
        indexes[rec.source] = rec.idx;
        newRec.indexes = _.clone(indexes);
      } else {
        // Multiple data sources with the same replacedAt time
        // so add to the current record.
        newRec[rec.source] = {
          fields: rec.fields
        };
        indexes[rec.source] = rec.idx;
        newRec.indexes = _.clone(indexes);
      }
    }
  });
  // Add the final record.
  mergeLog.push(newRec);

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
 * prenatalFormatted()
 *
 * Return all of the historical records as shown on the
 * prenatal page in the format expected by the front-end.
 * -------------------------------------------------------- */
//var prenatalFormatted = function(req, res) {
  //var pregId;

  //if (req.parameters && req.parameters.id1) {
    //pregId = req.parameters.id1;
  //} else {
    //// Bad request since the proper parameter not specified.
    //res.statusCode = 400;
    //return res.end();
  //}

  //return prenatal(pregId)
    //.then(function(data) {
      //// Adjust the data per caller requirements.

      //data = collateRecs(data, 'replacedAt');
      //mergeRecs(data, 'replacedAt');

      //res.end(JSON.stringify(data));
    //});
//};


/* --------------------------------------------------------
 * pregnancyFormatted()
 *
 * Return all of the historical records for a specfic
 * pregnancy formatted for the front-end.
 * -------------------------------------------------------- */
//var pregnancyFormatted = function(req, res) {
  //var pregId;

  //if (req.parameters && req.parameters.id1) {
    //pregId = req.parameters.id1;
  //} else {
    //// Bad request since the proper parameter not specified.
    //res.statusCode = 400;
    //return res.end();
  //}

  //return pregnancy(pregId)
    //.then(function(data) {
      //// Adjust the data per caller requirements.

      //data = collateRecs(data, 'replacedAt');
      //mergeRecs(data, 'replacedAt');

      //res.end(JSON.stringify(data));
    //});
//};


/* --------------------------------------------------------
 * prenatal()
 *
 * Return all of the historical records as show on the
 * prenatal page for the various tables per the pregnancy id
 * specified.
 * -------------------------------------------------------- */
//var prenatal = function(pregId) {
  //var knex
    //, sqlRisk
    //, riskData
    //;

  //// --------------------------------------------------------
  //// Historical tables for the prenatal page include:
  ////    pregnancyLog, patientLog, riskLog
  //// --------------------------------------------------------
  //sqlRisk = 'SELECT * FROM riskLog WHERE pregnancy_id = ? ORDER BY replacedAt';

  //return new Promise(function(resolve, reject) {
    //knex = Bookshelf.DB.knex;

    //return pregnancy(pregId)
      //.then(function(data) {
        //return knex
          //.raw(sqlRisk, pregId)
          //.then(function(data) {
            //riskData = data[0];
          //})
          //.then(function() {
            //// Merge the data into one object.
            //data.riskLog = riskData;
            //return resolve(data);
          //});
      //});
  //});
//};

/* --------------------------------------------------------
 * pregnancy()
 *
 * Return the pregnancy historical records for the pregnancy.
 * This information will be used across nearly all pages. This
 * includes the patient information as well.
 * -------------------------------------------------------- */
//var pregnancy = function(pregId) {
  //var knex
    //, sqlPreg
    //, sqlPat
    //, pregData
    //, patData
    //, allData = {}
    //;

  //// --------------------------------------------------------
  //// Historical tables: pregnancyLog and patientLog.
  //// --------------------------------------------------------
  //sqlPreg = 'SELECT * FROM pregnancyLog WHERE id = ? ORDER BY replacedAt';
  //sqlPat  = 'SELECT * FROM patientLog WHERE id = ? ORDER BY replacedAt';

  //return new Promise(function(resolve, reject) {
    //knex = Bookshelf.DB.knex;
    //return knex
      //.raw(sqlPreg, pregId)
      //.then(function(data) {
        //pregData = data[0];
      //})
      //.then(function() {
        //return knex.raw(sqlPat, pregData[0].patient_id);
      //})
      //.then(function(data) {
        //patData = data[0];
      //})
      //.then(function() {
        //// Merge the data into one object.
        //allData.pregnancyLog = pregData;
        //allData.patientLog = patData;
        //return resolve(allData);
      //});
  //});
//};

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


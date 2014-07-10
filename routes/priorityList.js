/*
 * -------------------------------------------------------------------------------
 * priorityList.js
 *
 * Handles interactive priority list of current clients in the priority queue.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , Promise = require('bluebird')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , cfg = require('../config')
  , Patient = require('../models').Patient
  , Patients = require('../models').Patients
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , Priority = require('../models').Priority
  , Priorities = require('../models').Priorities
  , Event = require('../models').Event
  , EventType = require('../models').EventType
  , EventTypes = require('../models').EventTypes
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , prenatalCheckInId
  , prenatalCheckOutId
  , prenatalChartPulledId
  ;


/* --------------------------------------------------------
 * init()
 *
 * Initialize the module.
 * -------------------------------------------------------- */
var init = function init() {
  // --------------------------------------------------------
  // Do a one time load of EventType ids.
  // --------------------------------------------------------
  new EventTypes()
    .fetch()
    .then(function(list) {
      prenatalCheckInId = list.findWhere({name: 'prenatalCheckIn'}).get('id');
      prenatalCheckOutId = list.findWhere({name: 'prenatalCheckOut'}).get('id');
      prenatalChartPulledId = list.findWhere({name: 'prenatalChartPulled'}).get('id');
    });
  logInfo('priorityList route module initialized.');
};

/* --------------------------------------------------------
 * load()
 *
 * Loads the client information specified in the url and
 * populates the request object with it.
 * -------------------------------------------------------- */
var load = function load(req, res, next) {
  var pregId = req.params.id
    , isChecked
    ;
  // --------------------------------------------------------
  // Sanity check.
  // --------------------------------------------------------
  if (! req.body.hasOwnProperty('isChecked')) {
    return next(new Error('Invalid parameters.'));
  }

  isChecked = JSON.parse(req.body.isChecked)
  req.paramPregnancy = {};
  req.paramPregnancy.id = pregId;
  req.paramPregnancy.isChecked = isChecked;
  next();
};

/* --------------------------------------------------------
 * page()
 *
 * Returns the page the displays the priority list. The page
 * does not have any data, just page structure. The data is
 * supplied via AJAX calls from the client to the data()
 * function.
 * -------------------------------------------------------- */
var page = function page(req, res) {
  var data = {
        title: req.gettext('Priority List')
        , messages: req.flash()
        , user: req.session.user
      }
    ;
  res.render('priorityList', data);
};

/* --------------------------------------------------------
 * data()
 *
 * Returns a JSON array of objects representing all the
 * client data that is currently in the priority queue.
 *
 * This is called by the client using AJAX.
 * -------------------------------------------------------- */
var data = function data(req, res) {
  var qryStr
    ;

  qryStr = 'SELECT preg.id id, pri.priority, e1.eDateTime checkIn, preg.lastname, ' +
    'preg.firstname, pat.dohID dohID, e2.eDateTime chartPulled, pe.weight wgt, ' +
    'pe.systolic, pe.diastolic, pe.cr > 0 prenatalExam, e3.eDateTime checkOut ' +
    'FROM event e1 INNER JOIN pregnancy preg ' +
    'ON e1.pregnancy_id = preg.id ' +
    'INNER JOIN patient pat ' +
    'ON preg.patient_id = pat.id ' +
    'LEFT OUTER JOIN priority pri ' +
    'ON pri.pregnancy_id = preg.id ' +
    'LEFT OUTER JOIN event e2 ' +
    'ON e2.eventType = ? AND e2.pregnancy_id = preg.id ' +
    'LEFT OUTER JOIN event e3 ' +
    'ON e3.eventType = ? AND e3.pregnancy_id = preg.id ' +
    'LEFT OUTER JOIN prenatalExam pe ' +
    'ON pe.pregnancy_id = preg.id ' +
    'AND pe.date = DATE(e1.eDateTime) ' +
    'WHERE e1.eventType IN (?) AND DATE(e1.eDateTime) = DATE(NOW()) ' +
    'GROUP BY preg.id ' +
    'ORDER BY e1.eDateTime ASC;';

  Bookshelf.DB.knex.raw(qryStr, [prenatalChartPulledId, prenatalCheckOutId,
      prenatalCheckInId])
    .then(function(records) {
      var recs = records[0]   // 2nd element in array is database stuff
        ;

      // --------------------------------------------------------
      // Some formatting, etc.
      // --------------------------------------------------------
      recs = _.map(recs, function(rec) {
        _.each(_.keys(rec), function(key) {
          if (! rec[key]) rec[key] = '';
          if (_.contains(['checkIn', 'checkOut', 'chartPulled'], key)) {
            rec[key] = _.isDate(rec[key])? moment(rec[key]).format('HH:mm A'): '';
          }
          if (key === 'dohID' && rec[key].length > 0) {
            rec[key] = rec[key].slice(0,2) + '-' + rec[key].slice(2,4) + '-' + rec[key].slice(4);
          }
        });
        return rec;
      });

      res.end(JSON.stringify(records[0]));
    });
};

/* --------------------------------------------------------
 * save()
 *
 * Saves data for the specified client. At the moment only
 * handles the chartPulled field.
 *
 * This is called by the client using AJAX.
 * -------------------------------------------------------- */
var save = function save(req, res) {
  var options = {}
    , pregId = req.paramPregnancy.id
    , isChecked = req.paramPregnancy.isChecked
    ;

  if (isChecked) {
    // --------------------------------------------------------
    // Create a ChartPulled event.
    // --------------------------------------------------------
    options.sid = req.sessionID;
    options.pregnancy_id = pregId;
    Event.prenatalChartEvent(options).then(function() {
      res.end();
    });
  } else {
    // --------------------------------------------------------
    // Find and remove the ChartPulled event for today.
    // --------------------------------------------------------
    Event.forge({eventType: prenatalChartPulledId, pregnancy_id: pregId})
      .query('where', 'eDateTime', '>', moment().format('YYYY-MM-DD'))
      .fetchAll()
      .then(function(records) {
        var rec
          ;
        // --------------------------------------------------------
        // Technically there could be more than one chart pulled
        // event for this client on a single day but it would only
        // make sense if the client checked in and out multiple times.
        // We will limit ourselves to deleting the most recent
        // chart pulled event.
        // --------------------------------------------------------
        records.comparator = 'eDateTime';
        records.sort();
        rec = records.at(records.length - 1);
        rec.destroy().then(function() {
          res.end();
        });
      });
  }
};

// Initialize the module.
init();

module.exports = {
  load: load
  , page: page
  , data: data
  , save: save
};



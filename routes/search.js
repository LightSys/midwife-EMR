/*
 * -------------------------------------------------------------------------------
 * search.js
 *
 * Functionality for searches.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , SelectData = require('../models').SelectData
  , cfg = require('../config')
  , hasRole = require('../auth').hasRole
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  ;

/* --------------------------------------------------------
 * view()
 *
 * Display the search form.
 * -------------------------------------------------------- */
var view = function(req, res) {
  var location
    , dayOfWeek
    , data = {
        title: req.gettext('Pregnancy Search')
        , user: req.session.user
        , messages: req.flash()
      }
    , refresh = function(dataName) {
        return new Promise(function(resolve, reject) {
          SelectData.getSelect(dataName)
            .then(function(list) {
              resolve(list);
            })
            .caught(function(err) {
              err.status = 500;
              reject(err);
            });
        });
      }
    ;

  return refresh('location')
    .then(function(list) {
      var l
        ;
      // --------------------------------------------------------
      // Insert an empty record as a default after unsetting the
      // current default.
      // --------------------------------------------------------
      l = _.map(list, function(obj) {obj.selected = false; return obj;})
      l.unshift({ selectKey: '', label: '', selected: true });
      location = l;
    })
    .then(function() {
      refresh('dayOfWeek')
        .then(function(list) {
          // --------------------------------------------------------
          // Insert an empty record as a default.
          // --------------------------------------------------------
          list.unshift({ selectKey: '', label: '', selected: true });
          dayOfWeek = list;
          data.prenatalDay = dayOfWeek;
          data.prenatalLocation = location;
          return res.render('search', data);
        });
    })
    .caught(function(err) {
      logError(err);
      return res.render('search', data);
    });
};

/* --------------------------------------------------------
 * execute()
 *
 * Perform the search using the parameters passed.
 *
 * param
 * return
 * -------------------------------------------------------- */
var execute = function(req, res) {
  var flds = _.omit(req.body, ['_csrf', 'searchType', 'next', 'previous'])
    , pageNum = 1
    , rowsPerPage = parseInt(cfg.search.rowsPerPage, 10)
    , priorityQry = flds.priority && flds.priority.length > 0 && parseInt(flds.priority, 10) !== NaN
    , qb
    , results = []
    , cols = [
        'patient.dob'
        , 'patient.dohID'
        , 'pregnancy.id'
        , 'pregnancy.firstname'
        , 'pregnancy.lastname'
        , 'pregnancy.address'
        , 'pregnancy.barangay'
        , 'priority.priority'
      ]
    , fnOp = '='
    , lnOp = '='
    , otherOp = '='
    , renderData
    ;

  // --------------------------------------------------------
  // Store the search criteria in the session so that it is
  // there if pagination is needed.
  // --------------------------------------------------------
  if (req.body.searchType === 'new') {
    req.session.searchFlds = flds;
    req.session.searchPage = pageNum;
    req.session.save();
  } else {
    if (req.body.next) {
      pageNum = req.session.searchPage = req.session.searchPage + 1;
    } else if (req.body.previous) {
      pageNum = req.session.searchPage = req.session.searchPage - 1;
    }
    flds = req.session.searchFlds || flds;
    req.session.save();
  }

  qb = new Pregnancy().query();
  qb.join('patient', 'patient.id', 'pregnancy.patient_id');
  if (priorityQry) {
    // --------------------------------------------------------
    // A Priority number was specified in the query so that
    // overrides all other parameters.
    // --------------------------------------------------------
    qb.join('priority', 'priority.pregnancy_id', 'pregnancy.id');
    qb.where('priority.priority', '=', flds.priority);
  } else {
    // --------------------------------------------------------
    // Get all records matching the query parameters but make
    // sure that if records have priority numbers assigned, that
    // they are at the top in ascending order.
    //
    // Note: in order to get the records that have an assigned
    // priority number to the top AND in ascending order, we will
    // need to do a union. For the moment we are satisfied with
    // getting the priority records to the top using the order
    // by clause below though we have to sacrifice our preference
    // for ascending order in order to allow the priority records
    // to appear first.
    // --------------------------------------------------------
    qb.leftOuterJoin('priority', 'priority.pregnancy_id', 'pregnancy.id');
    if (flds.firstname && flds.firstname.length > 0) {
      if (flds.firstname.indexOf('%') !== -1) {
        fnOp = 'LIKE';
      }
      qb.where('firstname', fnOp, flds.firstname);
    }
    if (flds.lastname && flds.lastname.length > 0) {
      if (flds.lastname.indexOf('%') !== -1) {
        lnOp = 'LIKE';
      }
      qb.where('lastname', lnOp, flds.lastname);
    }
    if (flds.dob && flds.dob.length > 0) qb.where('dob', otherOp, flds.dob);
    if (flds.doh && flds.doh.length > 0) qb.orWhere('dohID', otherOp, flds.doh);
    if (flds.philHealth && flds.philHealth.length > 0) qb.orWhere('philHealth', otherOp, flds.philHealth);
    if ((flds.prenatalDay && flds.prenatalDay.length > 0) ||
        (flds.prenatalLocation && flds.prenatalLocation.length > 0)) {
      qb.join('schedule', 'schedule.pregnancy_id', 'pregnancy.id');
      qb.where('schedule.scheduleType', '=', 'Prenatal');
      if (flds.prenatalDay.length > 0) qb.andWhere('schedule.day', '=', flds.prenatalDay);
      if (flds.prenatalLocation.length > 0) qb.andWhere('schedule.location', '=', flds.prenatalLocation);
    }
  }

  qb.limit(rowsPerPage)
    .offset((rowsPerPage * (pageNum-1)))
    .select(cols)
    .orderBy('priority', 'desc')    // hack to get recs with priority numbers to top, though not correct order
    .then(function(list) {
      _.each(list, function(rec) {
        var r = _.pick(rec, 'priority', 'id', 'dob', 'dohID', 'firstname', 'lastname', 'address', 'barangay');
        r.dob = moment(r.dob).format('MM-DD-YYYY');
        results.push(r);
      });
    renderData = {
      title: req.gettext('Search Results')
      , user: req.session.user
      , results: results
      , pageNum: pageNum
      , isGuard: false
    };
    if (hasRole(req, 'guard')) {
      renderData.isGuard = true;
    }
    res.render('searchResults', renderData);
  });
};


module.exports = {
  view: view
  , execute: execute
};



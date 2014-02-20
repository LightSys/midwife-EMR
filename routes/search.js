/*
 * -------------------------------------------------------------------------------
 * search.js
 *
 * Functionality for searches.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  ;

var view = function(req, res) {
  res.render('search', {
    title: req.gettext('Patient Search')
    , user: req.session.user
  });
};

/* --------------------------------------------------------
 * execute()
 *
 * Perform the search. Fields firstname, lastname and dob
 * are ANDed, while the fields doh, philHealth, and
 * priority are ORed.
 *
 * TODO: implement search by priority number.
 *
 * param
 * return
 * -------------------------------------------------------- */
var execute = function(req, res) {
  var flds = _.omit(req.body, ['_csrf'])
    , qb
    results = []
    , cols = [
        'patient.dob'
        , 'patient.dohID'
        , 'pregnancy.id'
        , 'pregnancy.firstname'
        , 'pregnancy.lastname'
        , 'pregnancy.address'
        , 'pregnancy.barangay'
      ]
    ;
  qb = new Pregnancy().query();
  qb.join('patient', 'patient.id', '=', 'pregnancy.patient_id');
  if (flds.firstname && flds.firstname.length > 0) qb.where('firstname', '=', flds.firstname);
  if (flds.lastname && flds.lastname.length > 0) qb.where('lastname', '=', flds.lastname);
  if (flds.dob && flds.dob.length > 0) qb.where('dob', '=', flds.dob);
  if (flds.doh && flds.doh.length > 0) qb.orWhere('dohID', '=', flds.doh);
  if (flds.philHealth && flds.philHealth.length > 0) qb.orWhere('philHealth', '=', flds.philHealth);
  qb.select(cols).then(function(list) {
    _.each(list, function(rec) {
      var r = _.pick(rec, 'id', 'dob', 'dohID', 'firstname', 'lastname', 'address', 'barangay');
      r.dob = moment(r.dob).format('MMM D, YYYY');
      results.push(r);
    });
    res.render('searchResults', {
      title: req.gettext('Search Results')
      , user: req.session.user
      , results: results
    });
  });
};


module.exports = {
  view: view
  , execute: execute
};



/*
 * -------------------------------------------------------------------------------
 * search.js
 *
 * Search functionality for API calls from the client.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Pregnancy = require('../../models').Pregnancy
  , Pregnancies = require('../../models').Pregnancies
  //, SelectData = require('../../models').SelectData
  , cfg = require('../../config')
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , validOrVoidDate = require('../../util').validOrVoidDate
  ;


var advancedSearch = function(req, res) {



};

/* --------------------------------------------------------
 * simpleSearch()
 *
 * Passed one search term, use it to query the lastname,
 * firstname, priority.barcode, philHealthID and other
 * fields as appropriate based upon the type of data in
 * the search term.
 * -------------------------------------------------------- */
var simpleSearch = function(req, res) {
  var searchPhrase = req.query.searchPhrase
    , searchType = 'string'
    , results = []
    , cols = [
        'patient.dob'
        , 'patient.dohID'
        , 'pregnancy.id'
        , 'pregnancy.firstname'
        , 'pregnancy.lastname'
        , 'pregnancy.address1'
        , 'pregnancy.address3'
        , 'priority.priority'
      ]
    , retVal
    , searchNumber
    , searchAlpha
    , searchAlphaParts
    , saIdx
    , saHead
    , saTail
    , qb
    , buildWhere
    ;

  // --------------------------------------------------------
  // Build a Knex grouped chain, optionally with an OR instead
  // of an AND clause.
  // --------------------------------------------------------
  buildWhere = function(qb, term, doOr) {
    var f = 'where';
    if (doOr) f = 'orWhere';
    qb[f](function() {
      this.where('firstname', 'LIKE', term + '%');
      this.orWhere('lastname', 'LIKE', term + '%');
    });
  }

  // --------------------------------------------------------
  // Determine what fields we are searching against based upon
  // the search term passed.
  // --------------------------------------------------------
  searchNumber = parseInt(searchPhrase, 10);
  if (! _.isNaN(searchNumber)) {
    searchType = 'number';
  } else {
    // Assume an alpha search.
    searchAlpha = searchPhrase.trim();
  }
  console.log('Search type: ' + searchType);
  console.log(searchNumber);
  console.log(searchAlpha);

  qb = new Pregnancy().query();
  qb.join('patient', 'patient.id', 'pregnancy.patient_id');
  qb.leftOuterJoin('priority', 'priority.pregnancy_id', 'pregnancy.id');
  if (searchType === 'string') {
    // --------------------------------------------------------
    // Search by each word in the searchPhrase for a match in
    // the first and last name fields. Also, allow for a full
    // match of the searchPhrase in either field. Finally, allow
    // for various combinations of words split across the first
    // and last name fields.
    // E.g. Assuming an existing patient: Suring, Mary Ann
    // These search phrases will match this record:
    //  mary ann
    //  mary sur
    //  suring
    //  mary ann sur
    // --------------------------------------------------------

    // --------------------------------------------------------
    // Search by each word in each field.
    // --------------------------------------------------------
    searchAlphaParts = searchAlpha.split(' ')
    for (var i = 0; i < searchAlphaParts.length; i++) {
      buildWhere(qb, searchAlphaParts[i]);
    }

    // --------------------------------------------------------
    // Matches the full searchAlpha in either field.
    // --------------------------------------------------------
    buildWhere(qb, searchAlpha, true);

    // --------------------------------------------------------
    // Matches combinations of words in the fields.
    // --------------------------------------------------------
    saIdx = searchAlpha.indexOf(' ');
    while (saIdx !== -1) {
      saHead = searchAlpha.substring(0, saIdx);
      saTail = searchAlpha.substring(saIdx).trim();
      saIdx = searchAlpha.indexOf(' ', saIdx + 1);
      buildWhere(qb, saHead, true);
      buildWhere(qb, saTail, false);
    }

  } else {
    // --------------------------------------------------------
    // Number search: search these fields: patient.dohID.
    // --------------------------------------------------------
    qb.where('patient.dohID', searchNumber);
  }
  qb.select(cols)
    .orderBy('priority', 'desc')    // hack to get recs with priority numbers to top, though not correct order
    //.then(function() {
      //console.log(qb.toString());
    //})
    .then(function(list) {
      _.each(list, function(rec) {
        var r = _.pick(rec, 'priority', 'id', 'dob', 'dohID', 'firstname', 'lastname', 'address1', 'address3');
        r.dob = validOrVoidDate(r.dob);
        results.push(r);
      })
    })
    .then(function() {
      retVal = JSON.stringify(results);
      res.end(retVal);
    });

};

/* --------------------------------------------------------
 * search()
 *
 * Determines what type of search is required and passes
 * control to the appropriate function.
 * -------------------------------------------------------- */
var search = function(req, res) {
  if (req.query && req.query.searchPhrase) {
    return simpleSearch(req, res);
  }
  return advancedSearch(req, res);
}

module.exports = {
  search: search
};

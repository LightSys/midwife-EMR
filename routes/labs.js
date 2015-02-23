/*
 * -------------------------------------------------------------------------------
 * labs.js
 *
 * Handling of adding, editing, and deleting lab tests that are displayed on
 * the main labs page.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Promise = require('bluebird')
  , Bookshelf = require('bookshelf')
  , cfg = require('../config')
  , hasRole = require('../auth').hasRole
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , adjustSelectData = require('../util').adjustSelectData
  , getCommonFormData = require('./pregnancy').getCommonFormData
  , LabSuite = require('../models').LabSuite
  , LabSuites = require('../models').LabSuites
  , LabTest = require('../models').LabTest
  , LabTests = require('../models').LabTests
  , LabTestValue = require('../models').LabTestValue
  , LabTestValues = require('../models').LabTestValues
  , LabTestResult = require('../models').LabTestResult
  , LabTestResults = require('../models').LabTestResults
  ;


/* --------------------------------------------------------
 * labTestAddForm()
 *
 * Displays the form that the user fills out for a specific
 * suite of tests.
 *
 * Note that this is generated via a POST instead of a GET
 * because the user specified in the form which lab suite
 * to use. This produces a form that contains all of the
 * tests within the chosen suite.
 * -------------------------------------------------------- */
var labTestAddForm = function(req, res) {
  var data
    , testIds = []
    , testDate
    ;
  if (req.paramPregnancy) {
    // --------------------------------------------------------
    // Get the test ids and the test date.
    // --------------------------------------------------------
    _.each(req.body, function(val, key) {
      if (key.search(/^labtest-/) !== -1) {
        testIds.push(parseInt(key.match(/\d+/), 10));
      }
    });
    testDate = req.body.labTestDate || void 0;

    if (testDate && testIds.length > 0) {
      new LabTests()
        .query(function(qb) {
          qb.whereIn('id', testIds);
        })
        .fetch({withRelated: ['LabTestValue']})
        .then(function(testList) {
          var labTests = []
            , formData = {
                title: req.gettext('Add Lab Tests')
                , labTestResultDate: testDate
                , addLabsDate: testDate
              }
            ;

          // --------------------------------------------------------
          // Prepare the test data by putting it into the format used
          // by the Jade select mixins and sorting by value.
          // --------------------------------------------------------
          testList.each(function(test) {
            labTests.push(labTestFormat(test));
          });

          data = getCommonFormData(req, _.extend(formData, {labTests: labTests}));
          res.render('labs/defaultLab', data);
        });
    } else {
      req.flash('warning', req.gettext('You must specify a date and at least one test.'));
      res.redirect(cfg.path.pregnancyLabsEdit.replace(/:id/, req.paramPregnancy.id));
    }
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * labTestEditForm()
 *
 * Displays the form to edit an individual lab test result.
 * -------------------------------------------------------- */
var labTestEditForm = function(req, res) {
  var ltrId = req.paramLabTestResultId
    ;
  if (req.paramPregnancy && ltrId) {
    LabTestResult.forge({id: ltrId})
      .fetch()
      .then(function(rst) {
        var labTestId = rst.get('labTest_id')
          , result = rst.get('result')
          , result2 = rst.get('result2')
          , warn = rst.get('warn')
          , testDate = rst.get('testDate')
          ;
        LabTest.forge({id: labTestId})
          .fetch({withRelated: ['LabTestValue']})
          .then(function(labTest) {
            LabSuite.forge({id: labTest.get('labSuite_id')})
              .fetch()
              .then(function(suite) {
                  var formData = {
                    title: req.gettext('Edit Lab Test: ' + labTest.get('name'))
                    , labTestResultId: ltrId
                    , labTestResultDate: moment(testDate).format('YYYY-MM-DD')
                  }
                  , data
                  , ltf = labTestFormat(labTest, result, result2, warn)
                  ;
                data = getCommonFormData(req, _.extend(formData, {labTests: [ltf]}));
                res.render('labs/defaultLab', data);
              });
          });
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * labTestSave()
 *
 * Add or update labTestResult records.
 *
 * For new lab results, creates new lab results in the
 * database for a single lab suite which may contain more
 * than one lab test. This results in inserting multiple
 * records into the labTestResult table within one transaction.
 *
 * For updates of lab results, still uses a transaction but
 * existing records are updated rather than inserted.
 * -------------------------------------------------------- */
var labTestSave = function(req, res) {
  var supervisor = null
    , testDate = req.body.testDate
    , flds = _.omit(req.body, ['_csrf', 'testDate'])
    , testResults = {}
    , isUpdate = _.has(req, 'paramLabTestResultId')
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Consolidate our results in preparation for storage into
    // the testResults array.
    // --------------------------------------------------------
    _.each(flds, function(val, key) {
      var fldType = key.split('-')[0]
        , testId = key.split('-')[1]
        ;
      if (val.length === 0) return;
      if (fldType === 'displayField') return; // Eliminate displayField for date.
      if (! testResults[testId]) {
        testResults[testId] = {
          labTest_id: testId
          , pregnancy_id: req.paramPregnancy.id
          , testDate: testDate
          , result: ''
          , result2: ''
          , warn: null
        };
        if (isUpdate) {
          // This is an update, not an insert so add the id.
          // The existence of the id will cause the ORM to
          // do an update rather than an insert into the DB.
          testResults[testId].id = req.paramLabTestResultId;
        }
      }
      if (fldType === 'warn' && val === '1') testResults[testId].warn = true;

      // --------------------------------------------------------
      // Number always overrides the select if both are provided.
      // --------------------------------------------------------
      if (fldType === 'numberLow' &&
        _.isNumber(Number(val))) testResults[testId].result = val;
      if (fldType === 'numberHigh' &&
        _.isNumber(Number(val))) testResults[testId].result2 = val;
      if (fldType === 'number' &&
        _.isNumber(Number(val))) testResults[testId].result = val;
      if (fldType === 'select') {
        if (testResults[testId].result.length === 0) {
          testResults[testId].result = val;
        }
      }
      if (fldType === 'text') testResults[testId].result = val;
    });

    // --------------------------------------------------------
    // Insert or update all of the records as a single transaction.
    // --------------------------------------------------------
    Bookshelf.DB.knex.transaction(function(t) {
      return Promise.all(Promise.map(_.toArray(testResults), function(tst) {
        return LabTestResult.forge(tst)
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(supervisor)
          .save(null, {transacting: t})
          .then(function(model) {
            return model;
          })
          .caught(function(err) {
            throw err;  // Any errors will cause all records to be rolled back.
          });
      }))
      .then(function(rows) {
        // No errors but not committed yet.
        logInfo('Committed ' + rows.length + ' records.');
        return true;
      })
      .caught(function(err) {
        // Errors but not rolled back yet.
        logError(err);
        logInfo('Transaction was rolled back.');
        req.flash('error', req.gettext('There was a problem and your changes were NOT saved.'));
        // We need to throw our way out of the transaction block
        // in order to signal a rollback.
        throw err;
      });
    })    // End transaction.
    .then(function() {
      // Transaction successful.
      res.redirect(cfg.path.pregnancyLabsEditForm.replace(/:id/, req.paramPregnancy.id));
    })
    .caught(function(err) {
      // Transaction failed.
      res.redirect(cfg.path.pregnancyLabsEditForm.replace(/:id/, req.paramPregnancy.id));
    });

  } else {
    logError('Error in update of labAdd(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * labDelete()
 *
 * Delete a specific labTestResult row.
 * -------------------------------------------------------- */
var labDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramLabTestResultId && req.body.labTestResultId &&
      req.body.labTestResultId == req.paramLabTestResultId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.labTestResultId = parseInt(flds.labTestResultId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ltr = new LabTestResult({id: flds.labTestResultId,
      pregnancy_id: flds.pregnancy_id});
    ltr
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted labTestResult with id: ' + flds.labTestResultId);
        req.flash('info', req.gettext('Lab Test Result was deleted.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};



/* --------------------------------------------------------
 * labTestFormat()
 *
 * Formats the JSON of a lab test in the format required
 * for the add or edit form.
 *
 * param       labTest - JSON representing labTest with labTestValue
 * param       result - the result the user already chose, if any
 * param       result2 - the high range of the result if a range
 * param       warn - if result, whether warning or not
 * return      labTestFormatted - JSON in correct format
 * -------------------------------------------------------- */
var labTestFormat = function(labTest, result, result2, warn) {
  var labTestOmitFlds = ['LabTestValue', 'updatedBy', 'updatedAt', 'supervisor']
    , data = _.omit(labTest.toJSON(), labTestOmitFlds)
    , ltVals = _.pluck(labTest.related('LabTestValue').toJSON(), 'value')
    , resultInVals = false
    ;
  data.result = result || void(0);
  data.result2 = result2 || void(0);
  data.warn = warn || void(0);
  if (ltVals.length > 0) {
    ltVals = _.map(ltVals, function(val) {
      if (! resultInVals && val === result) {
        resultInVals = true;
      }
      return {
        selectKey: val
        , selected: result && result === val? true: false
        , label: val
      };
    });
    // --------------------------------------------------------
    // Create an empty value as the default value and put it
    // at the top.
    // --------------------------------------------------------
    ltVals.push({selectKey: '', selected: true, label: ''});
    data.values = _.sortBy(ltVals, 'selectKey');
  }

  return data;
};

module.exports = {
  labTestAddForm: labTestAddForm
  , labTestEditForm: labTestEditForm
  , labTestSave: labTestSave
  , labDelete: labDelete
};



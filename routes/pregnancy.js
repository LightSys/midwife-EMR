/* 
 * -------------------------------------------------------------------------------
 * pregnancy.js
 *
 * Functionality for management of pregnancies.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , Promise = require('bluebird')
  , cfg = require('../config')
  , Patient = require('../models').Patient
  , Patients = require('../models').Patients
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  ;

var addForm = function(req, res) {
  // TODO: fix hard-coded marital status.
  var data = {
      title: req.gettext('New Pregnancy Record')
      , user: req.session.user
      , messages: req.flash()
      , marital: ['', 'Single', 'Live-in', 'Married', 'Widowed', 'Divorced', 'Separated']
    }
    ;
  res.render('pregnancyAddForm', data);
};

/* --------------------------------------------------------
 * create()
 *
 * Create a new patient record and the corresponding pregnancy
 * record to go along with it. Insures that the required fields
 * are provided otherwise does not change the database.
 *
 * param       req
 * param       res
 * return      undefined
 * -------------------------------------------------------- */
var create = function(req, res) {
  var common = {
        updatedBy: req.session.user.id
      }
    , dob = req.body.dob.length > 0? req.body.dob: null
    , doh = req.body.doh.length > 0? req.body.doh: null
    , pregFlds = _.omit(req.body, ['_csrf', 'dob'])
    , patFlds = {}
    ;

  if (req.session.roleInfo.isStudent) {
    common.supervisor = req.session.supervisor.id;
  }
  pregFlds = _.extend(pregFlds, common);
  patFlds = _.extend(common, {dob: dob, dohID: doh});

  // --------------------------------------------------------
  // Validate the fields.
  // --------------------------------------------------------
  Promise.all([Patient.checkFields(patFlds), Pregnancy.checkFields(pregFlds)])
    .then(function(result) {
      return _.object(['patFlds', 'pregFlds'], result);
    })
    // --------------------------------------------------------
    // Save patient and pregnancy records.
    // --------------------------------------------------------
    .then(function(flds) {
      Patient
        .forge(flds.patFlds)
        .save()
        .then(function(patient) {
          var pregFields = _.extend(flds.pregFlds, {patient_id: patient.get('id')});
          Pregnancy
            .forge(pregFields)
            .save()
            .then(function(pregnancy) {
              // TODO: should redirect to the edit form for the same pregnancy record.
              res.redirect(cfg.path.pregnancyNewForm);
            })
            .caught(function(e) {
              console.error('Error saving pregnancy record. Orphan patient record id: ' + patient.get('id'));
              throw e;
            });
        })
        .caught(function(e) {
          console.error('Error saving patient record: ' + e);
          throw e;
        });
    })
    .caught(function(e) {
      console.error(e);
      res.status(406);
      res.end();    // TODO: need a custom 406 page.
    });
};

module.exports = {
  addForm: addForm
  , create: create
};


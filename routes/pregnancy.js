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
  var data = {
      title: req.gettext('New Pregnancy Record')
      , user: req.session.user
      , messages: req.flash()
    }
    ;
  res.render('pregnancyAddForm', data);
};

var create = function(req, res) {
  var common = {
        updatedBy: req.session.user.id
      }
    , dob = req.body.dob.length > 0? req.body.dob: null
    ;

  if (req.session.roleInfo.isStudent) {
    common.supervisor = req.session.supervisor.id;
  }

  Patient.forge(_.extend(common, {dob: dob}))
    .save()
    .then(function(patient) {
      var flds = {
        patient_id: patient.get('id')
      };
      console.dir(patient.toJSON());
      Pregnancy.forge(_.extend(flds, common, _.omit(req.body, ['_csrf', 'dob'])))
        .save()
        .then(function(model) {
          console.dir(model.toJSON());
          res.redirect(cfg.path.pregnancyNewForm);
        })
        .catch(function(e) {
          console.error('Pregnancy error: ' + e);
        });
    })
    .catch(function(e) {
      console.error('Patient error: ' + e);
    });
};

module.exports = {
  addForm: addForm
  , create: create
};


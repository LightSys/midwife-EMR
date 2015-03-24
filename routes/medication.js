/*
 * -------------------------------------------------------------------------------
 * medication.js
 *
 * Handling of adding, editing, and deleting medications and vitamins on 
 * the main lab page.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , hasRole = require('../auth').hasRole
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , adjustSelectData = require('../util').adjustSelectData
  , getCommonFormData = require('./pregnancy').getCommonFormData
  , Pregnancy = require('../models').Pregnancy
  , Pregnancies = require('../models').Pregnancies
  , Medication = require('../models').Medication
  , Medications = require('../models').Medications
  , MedicationType = require('../models').MedicationType
  , MedicationTypes = require('../models').MedicationTypes
  ;

/* --------------------------------------------------------
 * medicationAddForm()
 *
 * Displays the form to add a new medication or vitamin.
 * -------------------------------------------------------- */
var medicationAddForm = function(req, res) {
  var data = {title: req.gettext('Add Medicine or Vitamin')};
  if (req.paramPregnancy) {
    new MedicationTypes()
      .fetch()
      .then(function(list) {
        // --------------------------------------------------------
        // Render the potential medication types in the form
        // required for the select drop down.
        // --------------------------------------------------------
        var medTypes = []
          ;
        _.each(_.sortBy(list.toJSON(), 'sortOrder'), function(mType) {
          var obj = {};
          obj.selectKey = mType.id;
          obj.label = mType.name;
          obj.selected = false;
          medTypes.push(obj);
        });
        data.medicationType = medTypes;
        res.render('medicationAddEditForm', getCommonFormData(req, data));
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * medicationEditForm()
 *
 * Displays the form to edit or delete an existing 
 * medicine or vitamin.
 * -------------------------------------------------------- */
var medicationEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Medicine or Vitamin')};
  if (req.paramPregnancy && req.paramMedicationId) {
    var medId = req.paramMedicationId
      ;
    Medication.forge({id: medId})
      .fetch({withRelated: ['medicationType']})
      .then(function(model) {
        var medication = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          , medType = model.related('medicationType')
          ;
        if (medication.date) {
          medication.date = moment(medication.date).format('YYYY-MM-DD');
        }
        data.medicationRec = medication;
        data.medicationRec.medType = medType.get('name');
        res.render('medicationAddEditForm', getCommonFormData(req, data));
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
 * medicationSave()
 *
 * Adds new medications or vitamins to the database or 
 * updates existing.
 * -------------------------------------------------------- */
var medicationSave = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // If this is an update, set the id so that the ORM does
    // an update rather than an insert.
    if (req.paramMedicationId) {
      flds.id = req.paramMedicationId;
    }

    // --------------------------------------------------------
    // Handle date, year, and month combinations.
    // --------------------------------------------------------
    if (flds.date.length === 0 || ! moment(flds.date, 'YYYY-MM-DD').isValid()) {
      var path = req.paramMedicationId? cfg.path.medicationEdit: cfg.path.medicationAdd
        ;
      path = path.replace(/:id/, flds.pregnancy_id);
      if (req.paramMedicationId) {
        path = path.replace(/:id2/, req.paramMedicationId);
      }
      req.flash('error', 'Must supply a medication date.');
      return res.redirect(path);
    }

    // --------------------------------------------------------
    // Insert into database after sanity check.
    // --------------------------------------------------------
    Medication.forge(flds)
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save()
      .then(function(model) {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        req.flash('info', req.gettext('Medication was saved.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in update of medicationSave(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * medicationDelete()
 *
 * Deletes a medication or vitamin from the database.
 * -------------------------------------------------------- */
var medicationDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramMedicationId && req.body.medicationId &&
      req.body.medicationId == req.paramMedicationId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.medicationId = parseInt(flds.medicationId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ref = new Medication({id: flds.medicationId, pregnancy_id: flds.pregnancy_id});
    ref
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Medication with id: ' + flds.medicationId);
        req.flash('info', req.gettext('Medication was deleted.'));
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


module.exports = {
  medicationAddForm: medicationAddForm
  , medicationEditForm: medicationEditForm
  , medicationSave: medicationSave
  , medicationDelete: medicationDelete
};


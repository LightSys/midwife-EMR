/*
 * -------------------------------------------------------------------------------
 * vaccination.js
 *
 * Handling of adding, editing, and deleting vaccinations on the main lab page.
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
  , Vaccination = require('../models').Vaccination
  , Vaccinations = require('../models').Vaccinations
  , VaccinationType = require('../models').VaccinationType
  , VaccinationTypes = require('../models').VaccinationTypes
  ;

/* --------------------------------------------------------
 * vaccinationAddForm()
 *
 * Displays the form to add a new vaccination.
 * -------------------------------------------------------- */
var vaccinationAddForm = function(req, res) {
  var data = {title: req.gettext('Add Vaccination')};
  if (req.paramPregnancy) {
    new VaccinationTypes()
      .fetch()
      .then(function(list) {
        // --------------------------------------------------------
        // Render the potential vaccination types in the form
        // required for the select drop down.
        // --------------------------------------------------------
        var vacTypes = []
          ;
        _.each(list.toJSON(), function(vType) {
          var obj = {};
          obj.selectKey = vType.id;
          obj.label = vType.name;
          obj.selected = false;
          vacTypes.push(obj);
        });
        data.vaccinationType = vacTypes;
        res.render('vaccinationAddEditForm', getCommonFormData(req, data));
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * vaccinationEditForm()
 *
 * Displays the form to edit or delete an existing vaccination.
 * -------------------------------------------------------- */
var vaccinationEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Vaccination')};
  if (req.paramPregnancy && req.paramVaccinationId) {
    var vacId = req.paramVaccinationId
      ;
    Vaccination.forge({id: vacId})
      .fetch({withRelated: ['vaccinationType']})
      .then(function(model) {
        var vaccination = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          , vacType = model.related('vaccinationType')
          ;
        if (vaccination.vacDate) {
          vaccination.vacDate = moment(vaccination.vacDate).format('YYYY-MM-DD');
        }
        data.vaccinationRec = vaccination;
        data.vaccinationRec.vacType = vacType.get('name');
        res.render('vaccinationAddEditForm', getCommonFormData(req, data));
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
 * vaccinationSave()
 *
 * Adds new vaccinations to the database or updates existing
 * vaccinations.
 * -------------------------------------------------------- */
var vaccinationSave = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    , defaultFlds = {
        administeredInternally: ''
      }
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // If this is an update, set the id so that the ORM does
    // an update rather than an insert.
    if (req.paramVaccinationId) {
      flds.id = req.paramVaccinationId;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    flds = _.extend(defaultFlds, flds);

    // --------------------------------------------------------
    // Handle date, year, and month combinations.
    // --------------------------------------------------------
    if (flds.vacDate.length > 0 && moment(flds.vacDate, 'YYYY-MM-DD').isValid()) {
      flds.vacMonth = null;
      flds.vacYear = null;
    } else {
      flds.vacDate = null;
      if (flds.vacYear.length === 0) {
        var path = req.paramVaccinationId? cfg.path.vaccinationEdit: cfg.path.vaccinationAdd;
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        if (req.paramVaccinationId) {
          path = path.replace(/:id2/, req.paramVaccinationId);
        }
        req.flash('error', 'Must supply a vaccination date or at least a year.');
        return res.redirect(path);
      }
    }

    // --------------------------------------------------------
    // Insert into database after sanity check.
    // --------------------------------------------------------
    Vaccination.forge(flds)
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save()
      .then(function(model) {
        var path
          ;
        if (flds.id) {
          // Redirect back to the main labs page if we are editing a pre-existing
          // record.
          path = cfg.path.pregnancyLabsEdit;
        } else {
          // Redirect to the next empty vaccination form for easily entering
          // multiple vaccination records.
          path = cfg.path.vaccinationAdd;
        }
        path = path.replace(/:id/, flds.pregnancy_id);
        req.flash('info', req.gettext('Vaccination was saved.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in update of vaccinationSave(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * vaccinationDelete()
 *
 * Deletes a vaccination from the database.
 * -------------------------------------------------------- */
var vaccinationDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramVaccinationId && req.body.vaccinationId &&
      req.body.vaccinationId == req.paramVaccinationId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.vaccinationId = parseInt(flds.vaccinationId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ref = new Vaccination({id: flds.vaccinationId, pregnancy_id: flds.pregnancy_id});
    ref
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Vaccination with id: ' + flds.vaccinationId);
        req.flash('info', req.gettext('Vaccination was deleted.'));
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
 * requiredTetanusSave()j
 *
 * Save the number of required tetanus shots that a specific
 * patient needs as determined by the staff.
 * -------------------------------------------------------- */
var requiredTetanusSave = function(req, res) {
  var flds = _.omit(req.body, ['_csrf'])
    , supervisor
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.numberRequiredTetanus) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    Pregnancy.forge({id: req.paramPregnancy.id})
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save({numberRequiredTetanus: flds.numberRequiredTetanus}, {patch: true})
      .then(function() {
        logInfo('Saved number required tetanus for patient ' + req.paramPregnancy.id);
        res.end();
      });
  } else {
    res.statusCode = 500;
    res.end();
  }
};


module.exports = {
  vaccinationAddForm: vaccinationAddForm
  , vaccinationEditForm: vaccinationEditForm
  , vaccinationSave: vaccinationSave
  , vaccinationDelete: vaccinationDelete
  , requiredTetanusSave: requiredTetanusSave
};


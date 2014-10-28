/* 
 * -------------------------------------------------------------------------------
 * prenatalExam.js
 *
 * Handling of adding, editing, and deleting prental exams on the prenatal page.
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
  , PrenatalExam = require('../models').PrenatalExam
  , PrenatalExams = require('../models').PrenatalExams
  , RoFieldsByRole = require('../models').RoFieldsByRole
  ;

/* --------------------------------------------------------
 * prentalExamAdd()
 *
 * Displays the form to add a prenatal exam.
 * -------------------------------------------------------- */
var prenatalExamAddForm = function(req, res) {
  var data = {title: req.gettext('Add Prenatal Exam')}
    , role = req.session.roleInfo.roleNames[0]
    , table = 'prenatalExam'
    ;
  if (req.paramPregnancy) {
    data = getCommonFormData(req, data);
    RoFieldsByRole
      .getTableFieldsByRole(role, table)
      .then(function(list) {
        data.readonlyFields = list;
        res.render('prenatalAddEditExam', data);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * prenatalExamEditForm()
 *
 * Displays the form to edit an existing prenatal exam.
 * -------------------------------------------------------- */
var prenatalExamEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Prenatal Exam')}
    , role = req.session.roleInfo.roleNames[0]
    , table = 'prenatalExam'
    ;
  if (req.paramPregnancy) {
    data = getCommonFormData(req, data);
    RoFieldsByRole
      .getTableFieldsByRole(role, table)
      .then(function(list) {
        data.readonlyFields = list;
        res.render('prenatalAddEditExam', data);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * prenatalExamSave()
 *
 * Creates or updates the prenatal exam record.
 * -------------------------------------------------------- */
var prenatalExamSave = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    , preRec
    , defaultFlds = {
        mvmt: '0'
        , vitamin: '0'
        , pray: '0'
      }
    , saveOpts = {method: 'update'}
    , role = req.session.roleInfo.roleNames[0]
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // --------------------------------------------------------
    // Allow 'unchecking' a box by providing a default of off.
    // --------------------------------------------------------
    flds = _.defaults(flds, defaultFlds);

    // --------------------------------------------------------
    // If a new record, remove empty id field and set method
    // for the sake of the ORM.
    // --------------------------------------------------------
    if (! !! flds.id) {
      delete flds.id;
      saveOpts.method = 'insert';
    }

    // --------------------------------------------------------
    // Store data in the position field all capitals.
    // --------------------------------------------------------
    if (flds.pos && flds.pos.length > 0) {
      flds.pos = flds.pos.toUpperCase();
    }

    // --------------------------------------------------------
    // Remove the fields that are read-only by role before saving.
    // --------------------------------------------------------
    RoFieldsByRole
      .getTableFieldsByRole(role, 'prenatalExam')
      .then(function(roFlds) {
        _.each(flds, function(val, key) {
          if (_.has(roFlds, key)) delete flds[key];
        });
        preRec = new PrenatalExam(flds);
        preRec
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(supervisor)
          .save(flds, saveOpts).then(function(model) {
            var path = cfg.path.pregnancyPrenatalEdit
              ;
            path = path.replace(/:id/, flds.pregnancy_id);
            req.flash('info', req.gettext('Prenatal Exam was saved.'));
            res.redirect(path);
          })
          .caught(function(err) {
            logError(err);
            // TODO: handle this better.
            res.redirect(cfg.path.search);
          });
      });
  } else {
    logError('Error in update of prenatalExam: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * prenatalExamDelete()
 *
 * Deletes a prenatal exam record.
 * -------------------------------------------------------- */
var prenatalExamDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , peRec
    ;

  if (req.paramPregnancy &&
      req.body &&
      req.paramPregnancy.id &&
      req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }
    flds.id = parseInt(flds.id, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    peRec = new PrenatalExam({id: flds.id, pregnancy_id: flds.pregnancy_id});
    peRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyPrenatalEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in delete of prental exam: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

module.exports = {
  prenatalExamAddForm: prenatalExamAddForm
  , prenatalExamEditForm: prenatalExamEditForm
  , prenatalExamSave: prenatalExamSave
  , prenatalExamDelete: prenatalExamDelete
};



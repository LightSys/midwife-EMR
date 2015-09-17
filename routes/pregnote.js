/*
 * -------------------------------------------------------------------------------
 * pregnote.js
 *
 * Handling of adding, editing, and deleting pregnancy notes on the main lab page.
 * Note that these notes are limited to progress notes for the time being, though
 * the pregnote table will handle other kinds of pregnancy notes.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , cfg = require('../config')
  , hasRole = require('../auth').hasRole
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , validOrVoidDate = require('../util').validOrVoidDate
  , adjustSelectData = require('../util').adjustSelectData
  , getCommonFormData = require('./pregnancy').getCommonFormData
  , Pregnote = require('../models').Pregnote
  , Pregnotes = require('../models').Pregnotes
  , pregnoteTypes          // Custom fields
  ;

/* --------------------------------------------------------
 * init()
 *
 * Initialize the module.
 * -------------------------------------------------------- */
var init = function() {
  // --------------------------------------------------------
  // Do a one time load of note types.
  // --------------------------------------------------------
  new PregnoteTypes()
    .fetch()
    .then(function(list) {
      pregnoteTypes = list.toJSON();
    });
};

/* --------------------------------------------------------
 * pregnoteAddForm()
 *
 * Displays the form to add a new pregnancy progress note.
 * -------------------------------------------------------- */
var pregnoteAddForm = function(req, res) {
  var data = {title: req.gettext('Add Progress Note')};
  if (req.paramPregnancy) {
    res.render('pregnoteAddEditForm', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * pregnoteEditForm()
 *
 * Displays the form to edit or delete an existing pregnancy progress note.
 * -------------------------------------------------------- */
var pregnoteEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Progress Note')};
  if (req.paramPregnancy && req.paramPregnoteId) {
    var pregId = req.paramPregnoteId
      ;
    Pregnote.forge({id: pregId})
      .fetch()
      .then(function(model) {
        var pregnote = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          ;
        pregnote.noteDate = validOrVoidDate(pregnote.noteDate);
        data.pregnoteRec = pregnote;
        res.render('pregnoteAddEditForm', getCommonFormData(req, data));
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
 * pregnoteSave()
 *
 * Adds new pregnancy progress note to the database or updates existing
 * pregnancy progress note.
 * -------------------------------------------------------- */
var pregnoteSave = function(req, res) {
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
    if (req.paramPregnoteId) {
      flds.id = req.paramPregnoteId;
    }

    // Set the note type as progress note.
    flds.pregnoteType = _.findWhere(pregnoteTypes, {name: 'prenatalProgress'}).id;

    // --------------------------------------------------------
    // Insert into database after sanity check.
    // --------------------------------------------------------
    Pregnote.forge(flds)
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save()
      .then(function(model) {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        req.flash('info', req.gettext('Progress note was saved.'));
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        res.redirect(cfg.path.search);
      });

  } else {
    logError('Error in update of pregnoteSave(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnoteDelete()
 *
 * Deletes a pregnancy progress note from the database.
 * -------------------------------------------------------- */
var pregnoteDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregnote
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramPregnoteId && req.body.pregnoteId &&
      req.body.pregnoteId == req.paramPregnoteId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.id = parseInt(flds.pregnoteId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    pregnote = new Pregnote({id: flds.id, pregnancy_id: flds.pregnancy_id});
    pregnote
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Progress note with id: ' + flds.pregnoteId);
        req.flash('info', req.gettext('Progress Note was deleted.'));
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

// --------------------------------------------------------
// Initialize the module.
// --------------------------------------------------------
init();

module.exports = {
  pregnoteAddForm: pregnoteAddForm
  , pregnoteEditForm: pregnoteEditForm
  , pregnoteSave: pregnoteSave
  , pregnoteDelete: pregnoteDelete
};


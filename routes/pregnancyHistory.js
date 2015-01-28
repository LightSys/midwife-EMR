/* 
 * -------------------------------------------------------------------------------
 * pregnancyHistory.js
 *
 * Handling of adding, editing, and deleting pregnancy histories on the
 * midwife interview page.
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
  , PregnancyHistory = require('../models').PregnancyHistory
  , PregnancyHistories = require('../models').PregnancyHistories
  ;


/* --------------------------------------------------------
 * pregnancyHistoryAddForm()
 *
 * Displays the historical pregnancy form for adding.
 * -------------------------------------------------------- */
var pregnancyHistoryAddForm = function(req, res) {
  var data = {title: req.gettext('Add Historical Pregnancy')};
  if (req.paramPregnancy) {
    res.render('midwifeInterviewAddPreg', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * pregnancyHistoryEditForm()
 *
 * Displays the historical pregnancy form for editing.
 * -------------------------------------------------------- */
var pregnancyHistoryEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Historical Pregnancy')};
  if (req.paramPregnancy) {
    res.render('midwifeInterviewEditPreg', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * pregnancyHistorySave()
 *
 * Creates or updates the historical pregnancy record.
 * -------------------------------------------------------- */
var pregnancyHistorySave = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregHistRec
    , defaultFlds = {
        FT: '0'
      }
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
    flds = _.extend(defaultFlds, _.omit(flds, ['_csrf']));

    // --------------------------------------------------------
    // Allow nulls in numeric fields that user does not fill
    // instead of database default of 0 which can be confused
    // about whether the user meant 0 or no answer.
    // --------------------------------------------------------
    _.each(['lengthOfLabor', 'birthWeight', 'howLongBFed'], function(f) {
      if (flds[f].length === 0) flds[f] = null;
    });

    pregHistRec = new PregnancyHistory(flds);
    pregHistRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .save(flds).then(function(model) {
        var path = flds.id? cfg.path.pregnancyHistoryEdit: cfg.path.pregnancyHistoryAdd
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        path = path.replace(/:id2/, flds.id);
        res.redirect(path);
      })
      .caught(function(err) {
        logError(err);
        // TODO: handle this better.
        res.redirect(cfg.path.search);
      });
  } else {
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * pregnancyHistoryDelete()
 *
 * Deletes a new historical pregnancy record.
 * -------------------------------------------------------- */
var pregnancyHistoryDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , pregHistRec
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

    pregHistRec = new PregnancyHistory({id: flds.id, pregnancy_id: flds.pregnancy_id});
    pregHistRec
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyMidwifeEdit
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
    logError('Error in update of pregnancyHistory: pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};
module.exports = {
  pregnancyHistoryAddForm: pregnancyHistoryAddForm
  , pregnancyHistoryEditForm: pregnancyHistoryEditForm
  , pregnancyHistorySave: pregnancyHistorySave
  , pregnancyHistoryDelete: pregnancyHistoryDelete
};



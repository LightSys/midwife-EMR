/* 
 * -------------------------------------------------------------------------------
 * referral.js
 *
 * Handling of adding, editing, and deleting referrals on the main lab page.
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
  , Referral = require('../models').Referral
  , Referrals = require('../models').Referrals
  ;

/* --------------------------------------------------------
 * referralAddForm()
 *
 * Displays the form to add a new referral.
 * -------------------------------------------------------- */
var referralAddForm = function(req, res) {
  var data = {title: req.gettext('Add Referral')};
  if (req.paramPregnancy) {
    res.render('referralAddEditForm', getCommonFormData(req, data));
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * referralEditForm()
 *
 * Displays the form to edit or delete an existing referral.
 * -------------------------------------------------------- */
var referralEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Referral')};
  if (req.paramPregnancy && req.paramReferralId) {
    var refId = req.paramReferralId
      ;
    Referral.forge({id: refId})
      .fetch()
      .then(function(model) {
        var referral = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          ;
        referral.date = validOrVoidDate(referral.date);
        data.referralRec = referral;
        res.render('referralAddEditForm', getCommonFormData(req, data));
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
 * referralSave()
 *
 * Adds new referrals to the database or updates existing
 * referrals.
 * -------------------------------------------------------- */
var referralSave = function(req, res) {
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
    if (req.paramReferralId) {
      flds.id = req.paramReferralId;
    }

    // --------------------------------------------------------
    // Insert into database after sanity check.
    // --------------------------------------------------------
    Referral.checkFields(flds).then(function(flds) {
      Referral.forge(flds)
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(supervisor)
        .save()
        .then(function(model) {
          var path = cfg.path.pregnancyLabsEdit
            ;
          path = path.replace(/:id/, flds.pregnancy_id);
          req.flash('info', req.gettext('Referral was saved.'));
          res.redirect(path);
        })
        .caught(function(err) {
          logError(err);
          res.redirect(cfg.path.search);
        });
    })
    .caught(function(err) {
      logError(err);
      res.redirect(cfg.path.search);
    });

  } else {
    logError('Error in update of referralSave(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * referralDelete()
 *
 * Deletes a referral from the database.
 * -------------------------------------------------------- */
var referralDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    , ref
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramReferralId && req.body.referralId &&
      req.body.referralId == req.paramReferralId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.referralId = parseInt(flds.referralId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    ref = new Referral({id: flds.referralId, pregnancy_id: flds.pregnancy_id});
    ref
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Referral with id: ' + flds.referralId);
        req.flash('info', req.gettext('Referral was deleted.'));
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
  referralAddForm: referralAddForm
  , referralEditForm: referralEditForm
  , referralSave: referralSave
  , referralDelete: referralDelete
};


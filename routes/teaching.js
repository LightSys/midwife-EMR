/* 
 * -------------------------------------------------------------------------------
 * teaching.js
 *
 * Handling of adding, editing, and deleting health teachings on the main lab page.
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
  , Teaching = require('../models').Teaching
  , Teachings = require('../models').Teachings
  , User = require('../models').User
  ;

/* --------------------------------------------------------
 * teachingAddForm()
 *
 * Displays the form to add a new health teaching.
 * -------------------------------------------------------- */
var teachingAddForm = function(req, res) {
  var data = {title: req.gettext('Add Health Teaching')}
    , tSelect
    ;
  if (req.paramPregnancy) {
    data = getCommonFormData(req, data);
    // --------------------------------------------------------
    // Get users that are teachers in selectData format.
    // --------------------------------------------------------
    User.getTeachersSelectData()
      .then(function(selData) {
        if (! selData) selData = [];
        data.teachers = selData;
        res.render('teachingAddEditForm', data);
      });
  } else {
    // Pregnancy not found.
    res.redirect(cfg.path.search);
  }
};


/* --------------------------------------------------------
 * teachingEditForm()
 *
 * Displays the form to edit or delete an existing health teaching.
 * -------------------------------------------------------- */
var teachingEditForm = function(req, res) {
  var data = {title: req.gettext('Edit Health Teaching')};
  if (req.paramPregnancy && req.paramTeachingId) {
    var teachId = req.paramTeachingId
      ;
    data = getCommonFormData(req, data);
    Teaching.forge({id: teachId})
      .fetch()
      .then(function(model) {
        var teaching = _.omit(model.toJSON(), ['updatedBy', 'updatedAt', 'supervisor'])
          ;
        teaching.date = moment(teaching.date).format('YYYY-MM-DD');
        data.teachingRec = teaching;
        // --------------------------------------------------------
        // Get the teacher selectData options and set to the specified
        // teacher.
        // --------------------------------------------------------
        User.getTeachersSelectData()
          .then(function(selData) {
            data.teachers = adjustSelectData(selData, '' + teaching.teacher);
            res.render('teachingAddEditForm', data);
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
 * teachingSave()
 *
 * Adds new health teachings to the database or updates existing
 * health teachings.
 * -------------------------------------------------------- */
var teachingSave = function(req, res) {
  var supervisor = null
    , flds = _.omit(req.body, ['_csrf'])
    , msg = []
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    // If this is an update, set the id so that the ORM does
    // an update rather than an insert.
    if (req.paramTeachingId) {
      flds.id = req.paramTeachingId;
    }

    // --------------------------------------------------------
    // Sanity check that we have all of the fields we need.
    // --------------------------------------------------------
    if (! flds.teacher) msg.push('Please choose a teacher.');
    if (! flds.topic) msg.push('Please choose a topic.');
    if (! flds.date) msg.push('Please set the date.');
    if (msg.length > 0) {
      _.each(msg, function(m) {
        logError(m);
        req.flash('warning', req.gettext(m));
      });
      res.redirect(req.url);
    } else {
      // --------------------------------------------------------
      // Insert into database after sanity check.
      // --------------------------------------------------------
      Teaching.forge(flds)
        .setUpdatedBy(req.session.user.id)
        .setSupervisor(supervisor)
        .save()
        .then(function(model) {
          var path = cfg.path.pregnancyLabsEdit
            ;
          path = path.replace(/:id/, flds.pregnancy_id);
          req.flash('info', req.gettext('Health teaching was saved.'));
          res.redirect(path);
        })
        .caught(function(err) {
          logError(err);
          res.redirect(cfg.path.search);
        });
    }
  } else {
    logError('Error in update of teachingSave(): pregnancy not found.');
    // TODO: handle this better.
    res.redirect(cfg.path.search);
  }
};

/* --------------------------------------------------------
 * teachingDelete()
 *
 * Deletes a health teaching from the database.
 * -------------------------------------------------------- */
var teachingDelete = function(req, res) {
  var supervisor = null
    , flds = req.body
    ;

  if (req.paramPregnancy && req.body &&
      req.paramPregnancy.id && req.body.pregnancy_id &&
      req.paramPregnancy.id == req.body.pregnancy_id &&
      req.paramTeachingId && req.body.teachingId &&
      req.body.teachingId == req.paramTeachingId) {

    if (hasRole(req, 'attending')) {
      supervisor = req.session.supervisor.id;
    }

    flds.teachingId = parseInt(flds.teachingId, 10);
    flds.pregnancy_id = parseInt(flds.pregnancy_id, 10);

    teach = new Teaching({id: flds.teachingId, pregnancy_id: flds.pregnancy_id});
    teach
      .setUpdatedBy(req.session.user.id)
      .setSupervisor(supervisor)
      .destroy().then(function() {
        var path = cfg.path.pregnancyLabsEdit
          ;
        path = path.replace(/:id/, flds.pregnancy_id);
        logInfo('Deleted Health teaching with id: ' + flds.teachingId);
        req.flash('info', req.gettext('Health teaching was deleted.'));
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
  teachingAddForm: teachingAddForm
  , teachingEditForm: teachingEditForm
  , teachingSave: teachingSave
  , teachingDelete: teachingDelete
};


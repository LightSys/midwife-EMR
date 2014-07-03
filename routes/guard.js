/*
 * -------------------------------------------------------------------------------
 * guard.js
 *
 * Handling of guard functions.
 * -------------------------------------------------------------------------------
 */

var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , cfg = require('../config')
  , Priority = require('../models').Priority
  , Priorities = require('../models').Priorities
  , Event = require('../models').Event
  , EventType = require('../models').EventType
  , EventTypes = require('../models').EventTypes
  , hasRole = require('../auth').hasRole
  , logInfo = require('../util').logInfo
  , logWarn = require('../util').logWarn
  , logError = require('../util').logError
  , eventTypes
  , prenatalCheckInId
  , prenatalCheckOutId
  ;

/* --------------------------------------------------------
 * checkInOut()
 *
 * Display the checkin or checkout form depending on the
 * status of the client. This route is reached from two
 * paths, a search on existing clients and the New Patient
 * CheckIn menu option.
 * -------------------------------------------------------- */
var checkInOut = function(req, res) {
  var data = {
        title: req.gettext('Check In')
        , user: req.session.user
        , messages: req.flash()
        , rec: req.paramPregnancy || void(0)
        , isCheckIn: true
      }
    ;

  if (req.paramPregnancy) {
    // --------------------------------------------------------
    // Determine if the client is already checked in or not then
    // display either the checkin or checkout forms.
    // --------------------------------------------------------
    Priority.forge({pregnancy_id: req.paramPregnancy.id})
      .fetch()
      .then(function(model) {
        var priRec
          ;
        if (! model) {
          logInfo('Checking in pregnancy id: ' + req.paramPregnancy.id);
        } else {
          logInfo('Checking out pregnancy id: ' + req.paramPregnancy.id);
          data.title = req.gettext('Check Out');
          data.priorityNumber = model.get('priority');
          data.isCheckIn = false;
        }
        res.render('checkinout', data);
      });
  } else {
    // --------------------------------------------------------
    // This is a new patient that needs to check in. The checkin
    // timestamp is temporarily stored in the assigned field in
    // the priority table. When the pregnancy record is created,
    // checkin event is created properly.
    // --------------------------------------------------------
    data.title = req.gettext('New Patient Check In');
    res.render('checkinout', data);
  }
};


/* --------------------------------------------------------
 * checkInOutSave()
 *
 * Process the user's selection of either checkin or checkout.
 * -------------------------------------------------------- */
var checkInOutSave = function(req, res) {
  var isCheckIn = req.url.split('/').slice(-1)[0] === cfg.path.checkIn.split('/').slice(-1)[0]
    , priorityBarcode = req.body.priorityBarcode
    , currDateTime = moment().format('YYYY-MM-DD HH:mm:ss')
    , data = {
        title: req.gettext('Check In')
        , user: req.session.user
        , messages: req.flash()
        , rec: req.paramPregnancy || void(0)
        , isCheckIn: isCheckIn
      }
    , goToInOut = void(0) // go to the checkinout page, most likely due to user input error
    ;

  priorityBarcode = parseInt(priorityBarcode, 10);
  if (isNaN(priorityBarcode)) {
    logError('Barcode entered was not a number. Please try again.');
    req.flash('error', 'Barcode entered was not a number. Please try again.');
    data.messages = req.flash();
    if (! isCheckIn) data.title = req.gettext('Check Out');
    return res.render('checkinout', data);
  }

  if (req.paramPregnancy) {
    if (isCheckIn) {
      // --------------------------------------------------------
      // Checkin of returning patient.
      // --------------------------------------------------------
      Priority.forge({eType: prenatalCheckInId, barcode: priorityBarcode})
        .fetch()
        .then(function(priRec) {
          // --------------------------------------------------------
          // Sanity check.
          // --------------------------------------------------------
          if (! priRec) {
            req.flash('warning', req.gettext('Sorry, that priority # barcode was not found.'));
            goToInOut = true;
            return;
          }
          if (priRec.get('pregnancy_id') !== null) {
            req.flash('error', req.gettext('This priority number has already been assigned to another client.'));
            logError('In checkin route with priority number already assigned to another pregnancy.');
            goToInOut = true;
            return;
          }

          return Bookshelf.DB.knex.transaction(function(t) {
            priRec
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(null)
              .save({assigned: null, pregnancy_id: req.paramPregnancy.id}, {method: 'update', transacting: t})
              .then(function(priRec2) {
                var opts = {
                      eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                      , pregnancy_id: req.paramPregnancy.id
                      , sid: req.sessionID
                    }
                  ;
                return Event.prenatalCheckInEvent(opts, t).then(function() {
                  logInfo('Pregnancy id ' + req.paramPregnancy.id + ' has checked in.');
                  req.flash('info', 'The client was checked in with priority number ' + priRec2.get('priority'));
                });
              })
              .then(function() {
                t.commit();
              })
              .caught(function(err) {
                logError('Rolling back transaction');
                console.log(err);
                goToInOut = true;
                t.rollback();
              });
          }); // end transaction
        })
        .then(function(t) {
          if (goToInOut) {
            data.messages = req.flash();
            return res.render('checkinout', data);
          }
          return res.redirect(cfg.path.search);
        })
        .caught(function(err) {
          console.dir(err);
          if (goToInOut) {
            data.messages = req.flash();
            return res.render('checkinout', data);
          }
          return res.redirect(cfg.path.search);
        });
    } else {
      // --------------------------------------------------------
      // Checkout of patient.
      // --------------------------------------------------------
      data.title = req.gettext('Check Out');
      data.isCheckIn = false;
      Priority.forge({eType: prenatalCheckInId, barcode: priorityBarcode})
        .fetch()
        .then(function(priRec) {
          // --------------------------------------------------------
          // Sanity checks.
          // --------------------------------------------------------
          if (! priRec) {
            req.flash('warning', req.gettext('Sorry, that priority # barcode was not found.'));
            goToInOut = true;
            return;
          }
          if (priRec.get('pregnancy_id') != req.paramPregnancy.id) {
            req.flash('error', req.gettext('This priority number has not been assigned to this client.'));
            logError('In checkout route without priority number already assigned to pregnancy.');
            goToInOut = true;
            return;
          }

          return Bookshelf.DB.knex.transaction(function(t) {
            priRec
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(null)
              .save({assigned: null, pregnancy_id: null}, {method: 'update', transacting: t})
              .then(function(priRec2) {
                var opts = {
                      eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                      , pregnancy_id: req.paramPregnancy.id
                      , sid: req.sessionID
                    }
                  ;
                return Event.prenatalCheckOutEvent(opts, t).then(function() {
                  logInfo('Pregnancy id ' + req.paramPregnancy.id + ' has checked out.');
                  req.flash(req.gettext('The client has successfully checked out.'));
                });
              })
              .then(function() {
                t.commit();
              })
              .caught(function(err) {
                logError('Rolling back transaction');
                console.log(err);
                goToInOut = true;
                t.rollback();
              });
          }); // end transaction
        })
        .then(function(t) {
          if (goToInOut) {
            data.messages = req.flash();
            return res.render('checkinout', data);
          }
          return res.redirect(cfg.path.search);
        })
        .caught(function(err) {
          console.dir(err);
          if (goToInOut) {
            data.messages = req.flash();
            return res.render('checkinout', data);
          }
          return res.redirect(cfg.path.search);
        });
    }
  } else {
    // --------------------------------------------------------
    // New patient check in.
    // --------------------------------------------------------
    Priority.forge({eType: prenatalCheckInId, barcode: priorityBarcode})
      .fetch()
      .then(function(priRec) {
        // --------------------------------------------------------
        // Sanity checks.
        // --------------------------------------------------------
        if (! priRec) {
          req.flash('warning', req.gettext('Sorry, that priority # barcode was not found.'));
          return res.redirect(cfg.path.newCheckIn);
        }
        if (priRec.get('pregnancy_id') !== null) {
          req.flash('error', req.gettext('This priority number has already been assigned to another client.'));
          logError('In checkin route for new patient with priority number via pregnancy id already assigned to another pregnancy.');
          return res.redirect(cfg.path.newCheckIn);
        }
        if (priRec.get('assigned') !== null) {
          req.flash('error', req.gettext('This priority number has already been assigned to another client.'));
          logError('In checkin route for new patient with priority number via assigned field already assigned to another pregnancy.');
          return res.redirect(cfg.path.newCheckIn);
        }

        priRec
          .setUpdatedBy(req.session.user.id)
          .setSupervisor(null)
          .save({assigned: currDateTime}, {method: 'update'})
          .then(function(priRec2) {
            req.flash('info', req.gettext('Priority number ') + priRec2.get('priority') + req.gettext(' was assigned.'));
            return res.redirect(cfg.path.newCheckIn);
          });
      })
      .caught(function(err) {
        logError(err);
        req.flash('warning', req.gettext(err));
        return res.redirect(cfg.path.newCheckIn);
      });
  }   // end else
};


/* --------------------------------------------------------
 * init()
 *
 * Initialize the module by determining the eventType ids
 * that are needed.
 * -------------------------------------------------------- */
var init = function() {
  new EventTypes()
    .fetch()
    .then(function(list) {
      eventTypes = list.toJSON();
      prenatalCheckInId = list.findWhere({name: 'prenatalCheckIn'}).get('id');
      prenatalCheckOutId = list.findWhere({name: 'prenatalCheckOut'}).get('id');
    });
};
init();

module.exports = {
  checkInOut: checkInOut
  , checkInOutSave: checkInOutSave
};



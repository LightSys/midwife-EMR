/* 
 * -------------------------------------------------------------------------------
 * checkInOut.js
 *
 * Checkin and checkout clients using the priority barcode.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , Priority = require('../../models').Priority
  , Priorities = require('../../models').Priorities
  , Event = require('../../models').Event
  , EventType = require('../../models').EventType
  , EventTypes = require('../../models').EventTypes
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , statusObject = require('./utils').statusObject
  , sendData = require('../../comm').sendData
  , DATA_CHANGE = require('../../comm').DATA_CHANGE
  , eventTypes
  , prenatalCheckInId
  , prenatalCheckOutId
  ;

/* --------------------------------------------------------
 * checkInOut()
 *
 * Perform checkin and checkout for the priority barcode
 * and the optional pregnancy id, both of which are passed
 * in the body of the post.
 *
 * Logic:
 *  - Priority barcode and no pregnancy id
 *    - If barcode is already checked in, check client out.
 *    - If barcode is not checked in, check in for new pregnancy
 *      without an associated pregnancy record.
 *  - Priority barcode and pregnancy id
 *    - If barcode is already checked in, check out.
 *    - If barcode is not checked in, check in for the pregnancy.
 *
 * Returns an object with a success message.
 *
 * TODO: standardize how to return success for calls that do not return data.
 * TODO: standardize use of sendData for minor tables.
 *
 * -------------------------------------------------------- */
var checkInOut = function(req, res) {
  var barcode = req.body.barcode
    , pregId = req.body.pregId
    , priorityObject = {eType: prenatalCheckInId, barcode: barcode}
    , currDateTime = moment().format('YYYY-MM-DD HH:mm:ss')
    , success = false
    , msg = ''
    , result
    , priorityNumber
    ;

  if (! barcode) {
    // Error: no barcode passed.
    result = statusObject(req, false, 'No barcode passed.',
        {barcode: barcode, pregId: pregId, operation: void 0});
    return res.end(JSON.stringify(result));
  }

  // --------------------------------------------------------
  // Determine if a checkin or checkout is required. We do not
  // search by pregnancy_id in order to discover if the priority
  // number is already assigned to a different pregnancy.
  // --------------------------------------------------------
  Priority.forge(priorityObject)
    .fetch()
    .then(function(priRec) {
      var priRecPregId
        , priRecAssigned
        , handleError
        ;
      var priRecFound = !! priRec;
      if (priRecFound) {
        priRecPregId = priRec.get('pregnancy_id') || void 0;
        priRecAssigned = priRec.get('assigned') || void 0;
      }

      handleError = function(msg) {
        result = statusObject(req, false, msg,
            {barcode: barcode, pregId: pregId, operation: void 0});
        return res.end(JSON.stringify(result));
      }

      // --------------------------------------------------------
      // Sanity checks.
      // --------------------------------------------------------
      if (! priRecFound) {
        return handleError('Invalid barcode passed.');
      }
      if (priRecAssigned) {
        return handleError('Barcode passed is already used.');
      }
      if (priRecPregId && pregId && priRecPregId !== pregId) {
        return handleError('Pregnancy id passed does not match server record.');
      }
      if (priRecPregId && pregId && priRecPregId !== pregId) {
        return handleError('Invalid pregnancy id passed.');
      }

      if (priRecPregId) {
        // --------------------------------------------------------
        // Check out because the pregnancy id is already assigned
        // to a priority record.
        //
        // Note that we use priRecPredId in this section because we
        // do allow the client to check out by just passing a barcode
        // and no pregId.
        // --------------------------------------------------------
        Bookshelf.DB.knex.transaction(function(t) {
          priRec
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(null)
            .save({assigned: null, pregnancy_id: null}, {method: 'update', transacting: t})
            .then(function(priRec2) {
              var opts = {
                    eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                    , pregnancy_id: priRecPregId
                    , sid: req.sessionID
                  }
                ;
              return Event.prenatalCheckOutEvent(opts, t)
                .then(function() {
                  logInfo('Pregnancy id ' + priRecPregId + ' has checked out.');
                  t.commit();
                  priorityNumber = priRec2.get('priority');
                  success = true;
                })
                .caught(function(err) {
                  logError('Pregnancy id ' + priRecPregId + ' was not checked in due to error.');
                  t.rollback();
                  logError(err);
                });
            });
        })    // end transaction
        .then(function() {
          result = statusObject(req, success, msg,
              {barcode: barcode
              , priority: priorityNumber
              , pregId: priRecPregId
              , operation: 'checkout'}
          );
          res.end(JSON.stringify(result));

          // --------------------------------------------------------
          // Notify all clients of the change.
          // TODO: this is a pregnancy change but the table changed is
          // not pregnancy, but loading the pregnancy will get this
          // data. Need to inform interested clients that this pregnancy
          // needs to be reloaded.
          // --------------------------------------------------------
          if (success) {
            var data = {
              table: 'pregnancy',
              id: priRecPregId,
              updatedBy: req.session.user.id
            };
            return sendData(DATA_CHANGE, JSON.stringify(data));
          }
        });

      } else {
        // --------------------------------------------------------
        // Check in - of existing patients and new patients.
        // --------------------------------------------------------

        if (pregId) {

          // --------------------------------------------------------
          // Patient check in of an existing patient.
          // --------------------------------------------------------

          Bookshelf.DB.knex.transaction(function(t) {
            priRec
              .setUpdatedBy(req.session.user.id)
              .setSupervisor(null)
              .save({assigned: null, pregnancy_id: pregId}, {method: 'update', transacting: t})
              .then(function(priRec2) {
                var opts = {
                      eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                      , pregnancy_id: pregId
                      , sid: req.sessionID
                    }
                  ;
                return Event.prenatalCheckInEvent(opts, t)
                  .then(function() {
                    logInfo('Pregnancy id ' + pregId + ' has checked in.');
                    t.commit();
                    priorityNumber = priRec2.get('priority');
                    success = true;
                  })
                  .caught(function(err) {
                    logError('Pregnancy id ' + pregId + ' was not checked in due to error.');
                    t.rollback();
                    logError(err);
                  });
              });
          }) // end transaction
          .then(function() {
            result = statusObject(req, success, msg,
                {barcode: barcode
                , priority: priorityNumber
                , pregId: pregId
                , operation: 'checkin'}
            );
            res.end(JSON.stringify(result));

            // --------------------------------------------------------
            // Notify all clients of the change.
            // TODO: this is a pregnancy change but the table changed is
            // not pregnancy, but loading the pregnancy will get this
            // data. Need to inform interested clients that this pregnancy
            // needs to be reloaded.
            // --------------------------------------------------------
            if (success) {
              var data = {
                table: 'pregnancy',
                id: pregId,
                updatedBy: req.session.user.id
              };
              return sendData(DATA_CHANGE, JSON.stringify(data));
            }
          });

        } else {

          // --------------------------------------------------------
          // New patient check in before the patient/pregnancy records created.
          // --------------------------------------------------------

          priRec
            .setUpdatedBy(req.session.user.id)
            .setSupervisor(null)
            .save({assigned: currDateTime}, {method: 'update'})
            .then(function(priRec2) {
              priorityNumber = priRec.get('priority');
              logInfo('Priority number ' + priorityNumber + ' was assigned to a new patient.');
              success = true;
              result = statusObject(req, success, msg,
                  {barcode: barcode
                  , priority: priorityNumber
                  , operation: 'checkin'}
              );
              res.end(JSON.stringify(result));
            });
        }
      }
    });
}

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
}


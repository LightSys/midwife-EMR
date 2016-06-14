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
 *
 * -------------------------------------------------------- */
var checkInOut = function(payload, userInfo, cb) {
  var barcode = payload.barcode
    , pregId = payload.pregId
    , priorityObject = {eType: prenatalCheckInId, barcode: barcode}
    , currDateTime = moment().format('YYYY-MM-DD HH:mm:ss')
    , success = false
    , msg = ''
    , result
    , priorityNumber
    ;

  if (! barcode) {
    // Error: no barcode passed.
    return cb('Error in checkin/out - no barcode passed for pregId ' + pregId);
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

      // --------------------------------------------------------
      // Sanity checks.
      // --------------------------------------------------------
      if (! priRecFound) {
        return cb('Invalid barcode passed.');
      }
      if (priRecAssigned && ! priRecPregId) {
        // Barcode assigned to patient not yet entered into system, so cannot use.
        return cb('Barcode passed is already used.');
      }
      if (priRecPregId && pregId && priRecPregId !== pregId) {
        return cb('The server does not think that the barcode you scanned/typed belongs to that patient.');
      }
      if (priRecPregId && pregId && priRecPregId !== pregId) {
        return cb('Invalid pregnancy id passed.');
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
            .setUpdatedBy(userInfo.user.id)
            .setSupervisor(null)
            .save({assigned: null, pregnancy_id: null}, {method: 'update', transacting: t})
            .then(function(priRec2) {
              var opts = {
                    eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                    , pregnancy_id: priRecPregId
                    , sid: userInfo.sessionID
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
          result = {
            barcode: barcode,
            priority: priorityNumber,
            pregId: priRecPregId,
            operation: 'checkout'
          };
          cb(null, result);
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
              .setUpdatedBy(userInfo.user.id)
              .setSupervisor(null)
              .save({assigned: null, pregnancy_id: pregId}, {method: 'update', transacting: t})
              .then(function(priRec2) {
                var opts = {
                      eDateTime: moment().format('YYYY-MM-DD HH:mm:ss.SSS')
                      , pregnancy_id: pregId
                      , sid: userInfo.sessionID
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
            result = {
              barcode: barcode,
              priority: priorityNumber,
              pregId: pregId,
              operation: 'checkin'
            };
            cb(null, result);
          });

        } else {

          // --------------------------------------------------------
          // New patient check in before the patient/pregnancy records created.
          // --------------------------------------------------------

          priRec
            .setUpdatedBy(userInfo.user.id)
            .setSupervisor(null)
            .save({assigned: currDateTime}, {method: 'update'})
            .then(function(priRec2) {
              priorityNumber = priRec.get('priority');
              logInfo('Priority number ' + priorityNumber + ' was assigned to a new patient.');
              success = true;
              result = {
                barcode: barcode,
                priority: priorityNumber,
                operation: 'checkin'
              };
              cb(null, result);
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


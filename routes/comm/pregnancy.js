/* 
 * -------------------------------------------------------------------------------
 * pregnancy.js
 *
 * Data management for pregnancy and related tables.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , Pregnancy = require('../../models').Pregnancy
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  , eventTypes
  , prenatalCheckInId
  , prenatalCheckOutId
  ;


var savePrenatal = function(payload, userInfo, cb) {
  var preg = payload.preg
    ;

  // --------------------------------------------------------
  // TODO:
  // 1. Handle dates correctly. Is client sending GMT?
  // 2. Add remaining fields for prenatal.
  // --------------------------------------------------------

  Pregnancy.forge({id: preg.id})
    .fetch().then(function(pregnancy) {
      pregnancy
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(preg)
        .then(function(pregnancy) {
          logInfo('savePrenatal id: ' + pregnancy.get('id'));
          return cb(null, pregnancy.toJSON());
        })
        .caught(function(err) {
          logError(err);
          return cb(err);
        });
    });
}


module.exports = {
  savePrenatal: savePrenatal
}

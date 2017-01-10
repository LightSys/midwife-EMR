/* 
 * -------------------------------------------------------------------------------
 * lookupTables.js
 *
 * Management of various lookup tables.
 * ------------------------------------------------------------------------------- 
 */

var _ = require('underscore')
  , moment = require('moment')
  , Bookshelf = require('bookshelf')
  , Promise = require('bluebird')
  , cfg = require('../../config')
  , MedicationType = require('../../models').MedicationType
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  ;

var updateMedicationType = function(data, userInfo, cb) {
  var rec = data;

  MedicationType.forge({id: rec.id})
    .fetch().then(function(medicationType) {
      medicationType
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(_.omit(rec, 'pendingTransaction'))
        .then(function(rec2) {
          return cb(null, true);
        })
        .caught(function(err) {
          return cb(err);
        });
    });
};

module.exports = {
  updateMedicationType: updateMedicationType
};


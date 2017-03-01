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
        .save(_.omit(rec, 'pendingId'))
        .then(function(rec2) {
          return cb(null, rec2.id, true);
        })
        .caught(function(err) {
          return cb(err);
        });
    });
};

var addMedicationType = function(data, userInfo, cb) {
  var rec = _.omit(data, ['id', 'pendingId']);

  MedicationType.forge(rec)
    .setUpdatedBy(userInfo.user.id)
    .setSupervisor(userInfo.user.supervisor)
    .save({}, {method: 'insert'})
    .then(function(rec2) {
      return cb(null, true, rec2);
    })
    .caught(function(err) {
      return cb(err);
    });
};

var delMedicationType = function(data, userInfo, cb) {
  var rec = _.omit(data, ['stateId']);

  new MedicationType({id: rec.id})
    .destroy()
    .then(function(deletedRec) {
      return cb(null, true);
    })
    .caught(function(err) {
      return cb(err);
    });
};

module.exports = {
  addMedicationType: addMedicationType,
  updateMedicationType: updateMedicationType,
  delMedicationType: delMedicationType
};


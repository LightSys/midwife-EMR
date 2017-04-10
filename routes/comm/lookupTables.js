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
  , User = require('../../models').User
  , hasRole = require('../../auth').hasRole
  , logInfo = require('../../util').logInfo
  , logWarn = require('../../util').logWarn
  , logError = require('../../util').logError
  ;


var addUser = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['id', 'pendingId'];
  var existingUser = User.forge({username: rec.username});
  var user;

  // --------------------------------------------------------
  // Make sure the user does not already exist.
  // --------------------------------------------------------
  existingUser.fetch().then(function(user) {
    if (user) {
      return cb('Username is already taken.', false);
    }

    // --------------------------------------------------------
    // Insure there is a password specified.
    // --------------------------------------------------------
    if (rec.password.length < 8) {
      return cb('Password must be at least 8 characters long.', false);
    }

    // --------------------------------------------------------
    // Save the new user and return details to caller.
    // --------------------------------------------------------
    user = new User(_.omit(rec, omitFlds));
    user.hashPassword(rec.password, function(err, success) {
      if (err || ! success) {
        return cb(err, false);
      } else {
        user
          .setUpdatedBy(userInfo.user.id)
          .setSupervisor(userInfo.user.supervisor)
          .save({}, {method: 'insert'})
          .then(function(user2) {
            return cb(null, true, user2);
          })
          .caught(function(err) {
            return cb(err, false);
          });
      }
    });
  });
};

// --------------------------------------------------------
// Note: we only delete a user when the user has not changed
// any other records in the database. We use the database
// deletion constraints to catch this.
// --------------------------------------------------------
var delUser = function(data, userInfo, cb) {
  var rec = _.omit(data, ['stateId']);
  new User({id: rec.id})
    .destroy()
    .then(function(deletedRec) {
      return cb(null, true);
    })
    .caught(function(err) {
      return cb(err);
    });
};

var updateUser = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['stateId', 'password'];
  var user = new User({id: rec.id});

  if (rec.password.length >= 8) {
    user.fetch()
      .then(function(user) {
        user.hashPassword(rec.password, function(err, success) {
          if (err || ! success) {
            return cb(err, false);
          } else {
            user
              .setUpdatedBy(userInfo.user.id)
              .setSupervisor(userInfo.user.supervisor)
              .save(_.omit(rec, omitFlds))
              .then(function(rec2) {
                return cb(null, true, rec2.id);
              })
              .caught(function(err) {
                return cb(err, false);
              });
          }
        });
      });
  } else {
    user.fetch().then(function(user) {
      if (user) {
        user
          .setUpdatedBy(userInfo.user.id)
          .setSupervisor(userInfo.user.supervisor)
          .save(_.omit(rec, omitFlds))
          .then(function(rec2) {
            return cb(null, true, rec2.id);
          })
          .caught(function(err) {
            return cb(err, false);
          });
        } else {
          return cb('User not found.', false);
        }
    });
  }
};

var updateMedicationType = function(data, userInfo, cb) {
  var rec = data;
  var omitFlds = ['stateId'];

  MedicationType.forge({id: rec.id})
    .fetch().then(function(medicationType) {
      medicationType
        .setUpdatedBy(userInfo.user.id)
        .setSupervisor(userInfo.user.supervisor)
        .save(_.omit(rec, omitFlds))
        .then(function(rec2) {
          return cb(null, true, rec2.id);
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
  addMedicationType,
  updateMedicationType,
  addUser,
  delUser,
  updateUser,
  delMedicationType
};

